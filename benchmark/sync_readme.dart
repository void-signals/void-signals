import 'dart:io';

/// Syncs benchmark results from BENCHMARK_REPORT.md to README files
///
/// This script extracts the Results and Summary tables from BENCHMARK_REPORT.md
/// and inserts them between the markers in README files:
/// - benchmark/README.md: Full results and summary
/// - README.md & README_CN.md: Summary table only
void main() async {
  final reportFile = File('bench/BENCHMARK_REPORT.md');

  if (!reportFile.existsSync()) {
    print('Error: bench/BENCHMARK_REPORT.md not found');
    exit(1);
  }

  // Read report content
  final reportContent = await reportFile.readAsString();

  // Extract Results and Summary sections
  final resultsSection = _extractSection(
    reportContent,
    '## Results',
    '## Summary',
  );
  final summarySection = _extractSection(reportContent, '## Summary', null);

  if (resultsSection == null) {
    print('Error: Could not find Results section in report');
    exit(1);
  }

  // Extract version info from Results table header
  final versionMap = _extractVersionsFromHeader(resultsSection);

  // Update benchmark/README.md with full results
  await _updateBenchmarkReadme(resultsSection, summarySection);

  // Extract summary table for main README files and add version links
  final summaryTable = _extractSummaryTable(summarySection);
  if (summaryTable != null) {
    final summaryWithVersions = _addVersionsToSummary(summaryTable, versionMap);
    // Update root README.md
    await _updateMainReadme('../README.md', summaryWithVersions);
    // Update root README_CN.md
    await _updateMainReadme('../README_CN.md', summaryWithVersions);
  }
}

/// Update benchmark/README.md with full benchmark results
Future<void> _updateBenchmarkReadme(
  String resultsSection,
  String? summarySection,
) async {
  final readmeFile = File('README.md');

  if (!readmeFile.existsSync()) {
    print('Warning: benchmark/README.md not found, skipping');
    return;
  }

  // Build the new content to insert
  final buffer = StringBuffer();
  buffer.writeln('## Latest Benchmark Results');
  buffer.writeln();
  buffer.write(resultsSection.trim());
  buffer.writeln();
  if (summarySection != null) {
    buffer.writeln();
    buffer.write(summarySection.trim());
  }

  final newContent = buffer.toString();

  // Read README content
  var readmeContent = await readmeFile.readAsString();

  // Find and replace content between markers
  const startMarker = '<!-- BENCHMARK_RESULTS_START -->';
  const endMarker = '<!-- BENCHMARK_RESULTS_END -->';

  final startIndex = readmeContent.indexOf(startMarker);
  final endIndex = readmeContent.indexOf(endMarker);

  if (startIndex == -1 || endIndex == -1) {
    print('Warning: Markers not found in benchmark/README.md, skipping');
    return;
  }

  // Replace content between markers
  final before = readmeContent.substring(0, startIndex + startMarker.length);
  final after = readmeContent.substring(endIndex);

  final newReadme = '$before\n$newContent\n$after';

  // Write updated README
  await readmeFile.writeAsString(newReadme);

  print('✓ benchmark/README.md updated with latest benchmark results');
}

/// Update main README files with summary table only
Future<void> _updateMainReadme(String path, String summaryTable) async {
  final readmeFile = File(path);

  if (!readmeFile.existsSync()) {
    print('Warning: $path not found, skipping');
    return;
  }

  // Read README content
  var readmeContent = await readmeFile.readAsString();

  // Find and replace content between markers
  const startMarker = '<!-- BENCHMARK_SUMMARY_START -->';
  const endMarker = '<!-- BENCHMARK_SUMMARY_END -->';

  final startIndex = readmeContent.indexOf(startMarker);
  final endIndex = readmeContent.indexOf(endMarker);

  if (startIndex == -1 || endIndex == -1) {
    print('Warning: Summary markers not found in $path, skipping');
    return;
  }

  // Replace content between markers
  final before = readmeContent.substring(0, startIndex + startMarker.length);
  final after = readmeContent.substring(endIndex);

  final newReadme = '$before\n$summaryTable\n$after';

  // Write updated README
  await readmeFile.writeAsString(newReadme);

  print('✓ $path updated with latest benchmark summary');
}

/// Extract the summary table from the summary section
String? _extractSummaryTable(String? summarySection) {
  if (summarySection == null) return null;

  // Find the table in the summary section
  final lines = summarySection.split('\n');
  final tableLines = <String>[];
  var inTable = false;

  for (final line in lines) {
    if (line.trim().startsWith('|')) {
      inTable = true;
      tableLines.add(line);
    } else if (inTable && line.trim().isEmpty) {
      break;
    }
  }

  return tableLines.isNotEmpty ? tableLines.join('\n') : null;
}

/// Extract version info from the Results table header
/// Returns a map of framework name to version link markdown
Map<String, String> _extractVersionsFromHeader(String resultsSection) {
  final versionMap = <String, String>{};
  final lines = resultsSection.split('\n');

  // Find the header line (starts with | Test |)
  for (final line in lines) {
    if (line.trim().startsWith('| Test |')) {
      // Parse each column header
      // Format: framework_name ([version](url))
      final regex = RegExp(r'(\w+)\s*\(\[([^\]]+)\]\(([^)]+)\)\)');
      final matches = regex.allMatches(line);

      for (final match in matches) {
        final frameworkName = match.group(1)!;
        final version = match.group(2)!;
        final url = match.group(3)!;
        versionMap[frameworkName] =
            '[$frameworkName](https://pub.dev/packages/${_getPackageName(frameworkName)}) ([${version}]($url))';
      }
      break;
    }
  }

  return versionMap;
}

/// Get the actual package name for a framework
String _getPackageName(String framework) {
  const packageNameMap = {
    'state_beacon': 'state_beacon_core',
    'signals_core': 'signals_core',
    'alien_signals': 'alien_signals',
    'mobx': 'mobx',
    'preact_signals': 'preact_signals',
    'solidart': 'solidart',
    'void_signals': 'void_signals',
  };
  return packageNameMap[framework] ?? framework;
}

/// Add version links to the Summary table
String _addVersionsToSummary(
  String summaryTable,
  Map<String, String> versionMap,
) {
  final lines = summaryTable.split('\n');
  final result = <String>[];

  for (final line in lines) {
    if (line.contains('|') && !line.contains('---') && !line.contains('Rank')) {
      // This is a data row, replace framework name with version link
      var modifiedLine = line;
      for (final entry in versionMap.entries) {
        // Match the framework name that appears after | emoji | or | number |
        final pattern = RegExp(r'\|\s*' + entry.key + r'\s*\|');
        if (pattern.hasMatch(modifiedLine)) {
          modifiedLine = modifiedLine.replaceFirst(
            pattern,
            '| ${entry.value} |',
          );
        }
      }
      result.add(modifiedLine);
    } else {
      result.add(line);
    }
  }

  return result.join('\n');
}

/// Extract a section from markdown content
String? _extractSection(String content, String startHeader, String? endHeader) {
  final startIndex = content.indexOf(startHeader);
  if (startIndex == -1) return null;

  final contentStart = startIndex + startHeader.length;

  int contentEnd;
  if (endHeader != null) {
    contentEnd = content.indexOf(endHeader, contentStart);
    if (contentEnd == -1) {
      contentEnd = content.length;
    }
  } else {
    // Find next ## header or end of file
    final nextHeader = RegExp(
      r'\n## ',
    ).firstMatch(content.substring(contentStart));
    if (nextHeader != null) {
      contentEnd = contentStart + nextHeader.start;
    } else {
      contentEnd = content.length;
    }
  }

  return content.substring(contentStart, contentEnd).trim();
}
