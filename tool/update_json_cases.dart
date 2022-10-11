import 'dart:convert';
import 'dart:io';

import 'package:dart_markdown/dart_markdown.dart';

void main() {
  generateTestCases('common_mark');
  generateTestCases('gfm');
}

void generateTestCases(String flavorName) {
  final fileName = {
    'common_mark': 'tool/common_mark_tests.json',
    'gfm': 'tool/gfm_tests.json'
  }[flavorName];

  final url = {
    'common_mark': 'https://spec.commonmark.org/0.30',
    'gfm': 'https://github.github.com/gfm'
  }[flavorName];

  final root = File(Platform.script.path).parent.parent.path;
  final file = File('$root/$fileName');
  final json = file.readAsStringSync();
  final list = List<Map<String, dynamic>>.from(jsonDecode(json) as List);

  final testCases = <String, List<Map<String, dynamic>>>{};
  for (final item in list) {
    final sectionName = item['section'] as String;
    final markdown = item['markdown'] as String;
    final description = '$sectionName, $url/#example-${item['example']}';
    print(description);
    testCases[sectionName] ??= <Map<String, dynamic>>[];
    testCases[sectionName]!.add({
      'description': description,
      'markdown': markdown,
      'expected': _parseMarkdown(markdown),
    });
  }

  for (final entry in testCases.entries) {
    final fileName = _fileNameFromSection(entry.key);
    final outputPath = '$root/test/$flavorName/$fileName';
    final testCases = const JsonEncoder.withIndent('  ').convert(entry.value);
    File(outputPath).writeAsStringSync('$testCases\n');
  }
}

String _fileNameFromSection(String section) {
  var fileName = section.toLowerCase().replaceAll(RegExp(r'[ \)\(]+'), '_');
  while (fileName.endsWith('_')) {
    fileName = fileName.substring(0, fileName.length - 1);
  }
  return '$fileName.json';
}

/// Renders Markdown String to expected data.
List<Map<String, dynamic>> _parseMarkdown(String markdown) {
  return Markdown().parse(markdown).map((e) => e.toMap()).toList();
}
