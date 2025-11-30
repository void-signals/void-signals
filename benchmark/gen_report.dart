import 'dart:io';
import 'dart:convert';

/// Parse benchmark results from markdown files and generate combined report.
void main() async {
  final benchDir = Directory('bench');
  if (!benchDir.existsSync()) {
    print('Error: bench directory not found');
    exit(1);
  }

  final results = <String, Map<String, BenchResult>>{};
  final frameworks = <String>[];

  // Parse all markdown files
  await for (final file in benchDir.list()) {
    if (file is File && file.path.endsWith('.md')) {
      final framework = file.path.split('/').last.replaceAll('.md', '');
      if (framework == 'BENCHMARK_REPORT') continue;

      frameworks.add(framework);
      final content = await file.readAsString();
      final parsed = parseMarkdownResults(content);

      for (final entry in parsed.entries) {
        results.putIfAbsent(entry.key, () => {});
        results[entry.key]![framework] = entry.value;
      }
    }
  }

  if (frameworks.isEmpty) {
    print('No benchmark results found');
    exit(1);
  }

  // Package name mappings (framework name -> actual package name)
  final packageNameMap = <String, String>{
    'state_beacon': 'state_beacon_core',
    'signals_core': 'signals_core',
    'alien_signals': 'alien_signals',
    'mobx': 'mobx',
    'preact_signals': 'preact_signals',
    'solidart': 'solidart',
    'void_signals': 'void_signals',
  };

  // Read framework versions from pubspec.lock files
  final versions = await getFrameworkVersions(frameworks, packageNameMap);

  final sortedTests = results.keys.toList()..sort();

  // Calculate wins for each framework first (needed for sorting)
  final stats = <String, ({int wins, int total, int passed})>{};

  for (final f in frameworks) {
    int wins = 0;
    int total = 0;
    int passed = 0;

    for (final test in sortedTests) {
      final testResults = results[test]!;
      final result = testResults[f];
      if (result == null) continue;

      total++;
      if (result.passed) {
        passed++;

        // Check if this is the best time
        final validTimes = testResults.values
            .where((r) => r.passed)
            .map((r) => r.time)
            .toList();
        final bestTime = validTimes.reduce((a, b) => a < b ? a : b);
        if (result.time == bestTime) wins++;
      }
    }

    stats[f] = (wins: wins, total: total, passed: passed);
  }

  // Sort frameworks by wins (descending), then alphabetically for ties
  frameworks.sort((a, b) {
    final winsA = stats[a]?.wins ?? 0;
    final winsB = stats[b]?.wins ?? 0;
    if (winsA != winsB) return winsB.compareTo(winsA);
    return a.compareTo(b);
  });

  // Generate combined markdown report
  final buffer = StringBuffer();
  buffer.writeln('# Reactivity Benchmark Report');
  buffer.writeln();
  buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
  buffer.writeln();

  // Results table
  buffer.writeln('## Results');
  buffer.writeln();

  // Header row with version links
  buffer.write('| Test |');
  for (final f in frameworks) {
    final version = versions[f];
    final packageName = packageNameMap[f] ?? f;
    if (version != null) {
      buffer.write(
        ' $f ([${version}](https://pub.dev/packages/$packageName/versions/$version)) |',
      );
    } else {
      buffer.write(' $f |');
    }
  }
  buffer.writeln();

  // Separator row
  buffer.write('|------|');
  for (final _ in frameworks) {
    buffer.write('--------|');
  }
  buffer.writeln();

  // Data rows
  for (final test in sortedTests) {
    buffer.write('| $test |');

    // Find best time for this test
    final testResults = results[test]!;
    final validTimes = testResults.values
        .where((r) => r.passed)
        .map((r) => r.time)
        .toList();
    final bestTime = validTimes.isEmpty
        ? double.infinity
        : validTimes.reduce((a, b) => a < b ? a : b);

    for (final f in frameworks) {
      final result = testResults[f];
      if (result == null) {
        buffer.write(' N/A |');
      } else if (!result.passed) {
        buffer.write(' ❌ |');
      } else if (result.time == bestTime) {
        buffer.write(' **${formatTime(result.time)}** 🏆 |');
      } else {
        buffer.write(' ${formatTime(result.time)} |');
      }
    }
    buffer.writeln();
  }

  // Summary section
  buffer.writeln();
  buffer.writeln('## Summary');
  buffer.writeln();

  // Sort by wins for summary table
  final sorted = stats.entries.toList()
    ..sort((a, b) => b.value.wins.compareTo(a.value.wins));

  buffer.writeln('| Rank | Framework | Wins | Pass Rate |');
  buffer.writeln('|------|-----------|------|-----------|');

  for (var i = 0; i < sorted.length; i++) {
    final entry = sorted[i];
    final medal = switch (i) {
      0 => '🥇',
      1 => '🥈',
      2 => '🥉',
      _ => '${i + 1}',
    };
    final passRate = entry.value.total > 0
        ? (entry.value.passed / entry.value.total * 100).toStringAsFixed(0)
        : '0';
    buffer.writeln(
      '| $medal | ${entry.key} | ${entry.value.wins} | $passRate% |',
    );
  }

  // Save report
  await File('bench/BENCHMARK_REPORT.md').writeAsString(buffer.toString());
  print(buffer);

  // Also save JSON report
  final jsonReport = {
    'timestamp': DateTime.now().toIso8601String(),
    'frameworks': frameworks,
    'versions': versions,
    'results': results.map(
      (test, fResults) => MapEntry(
        test,
        fResults.map(
          (f, r) => MapEntry(f, {'time': r.time, 'passed': r.passed}),
        ),
      ),
    ),
    'summary': stats.map(
      (f, s) =>
          MapEntry(f, {'wins': s.wins, 'total': s.total, 'passed': s.passed}),
    ),
  };

  await File(
    'bench/benchmark_results.json',
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(jsonReport));
}

/// Get framework versions from pubspec.lock files
Future<Map<String, String>> getFrameworkVersions(
  List<String> frameworks,
  Map<String, String> packageNameMap,
) async {
  final versions = <String, String>{};

  for (final framework in frameworks) {
    final lockFile = File('frameworks/$framework/pubspec.lock');
    if (!lockFile.existsSync()) {
      // For void_signals, read version from its own pubspec.yaml
      if (framework == 'void_signals') {
        final pubspecFile = File('../packages/void_signals/pubspec.yaml');
        if (pubspecFile.existsSync()) {
          final content = await pubspecFile.readAsString();
          final versionMatch = RegExp(
            r'^version:\s*(.+)$',
            multiLine: true,
          ).firstMatch(content);
          if (versionMatch != null) {
            versions[framework] = versionMatch.group(1)!.trim();
          }
        }
      }
      continue;
    }

    final content = await lockFile.readAsString();
    final packageName = packageNameMap[framework] ?? framework;

    // Parse YAML-like pubspec.lock to find the package version
    final lines = content.split('\n');
    bool inTargetPackage = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if we're entering the target package section
      if (line.trim() == '$packageName:') {
        inTargetPackage = true;
        continue;
      }

      // If we're in the target package, look for version
      if (inTargetPackage) {
        final versionMatch = RegExp(
          r'^\s+version:\s*"?([^"]+)"?$',
        ).firstMatch(line);
        if (versionMatch != null) {
          versions[framework] = versionMatch.group(1)!.trim();
          break;
        }

        // If we hit another package (no indentation), we've left our target
        if (line.isNotEmpty &&
            !line.startsWith(' ') &&
            !line.startsWith('\t')) {
          break;
        }
      }
    }
  }

  return versions;
}

class BenchResult {
  final double time;
  final bool passed;

  BenchResult(this.time, this.passed);
}

Map<String, BenchResult> parseMarkdownResults(String content) {
  final results = <String, BenchResult>{};
  final lines = content.split('\n');

  for (final line in lines) {
    if (!line.startsWith('|') ||
        line.contains('---') ||
        line.contains('Test')) {
      continue;
    }

    final parts = line
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length < 2) continue;

    final test = parts[0];

    // Skip header rows and invalid test names
    if (test == 'Rank' ||
        test.startsWith('🥇') ||
        test.startsWith('🥈') ||
        test.startsWith('🥉')) {
      continue;
    }

    final value = parts[1];

    if (value == '❌' || value == 'N/A') {
      results[test] = BenchResult(0, false);
    } else {
      // Parse time value
      final timeStr = value.replaceAll('**', '').replaceAll('🏆', '').trim();
      final time = parseTime(timeStr);
      results[test] = BenchResult(time, true);
    }
  }

  return results;
}

double parseTime(String timeStr) {
  timeStr = timeStr.trim();

  try {
    if (timeStr.endsWith('μs')) {
      return double.parse(timeStr.replaceAll('μs', '').trim());
    } else if (timeStr.endsWith('ms')) {
      return double.parse(timeStr.replaceAll('ms', '').trim()) * 1000;
    } else if (timeStr.endsWith('s')) {
      return double.parse(timeStr.replaceAll('s', '').trim()) * 1000000;
    }

    return double.tryParse(timeStr) ?? 0;
  } catch (e) {
    print('Warning: Failed to parse time "$timeStr": $e');
    return 0;
  }
}

String formatTime(double microseconds) {
  if (microseconds < 1000) {
    return '${microseconds.toStringAsFixed(0)}μs';
  } else if (microseconds < 1000000) {
    return '${(microseconds / 1000).toStringAsFixed(2)}ms';
  } else {
    return '${(microseconds / 1000000).toStringAsFixed(2)}s';
  }
}
