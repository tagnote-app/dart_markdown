// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:dart_markdown/dart_markdown.dart';
import 'package:dart_markdown/src/reverse_renderer.dart';
import 'package:path/path.dart' as p;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'util.dart';

void main() async {
  await simpleTest('common_mark');
  await simpleTest('gfm');
  await strictTest('common_mark');
  await strictTest('gfm');

  group('test task list', () {
    test('nested', () {
      const input = '''
- [x] foo
  - [ ] bar
  - [x] baz
- [ ] bim
''';
      final output = markdownToMarkdown(input, enableTaskList: true);
      expect(output, input);
    });

    test('hybrid', () {
      const input = '''
+ [x] foo
+ bar
+ [ ] baz
''';
      final output = markdownToMarkdown(input, enableTaskList: true);
      expect(output, input);
    });
  });
}

Future<void> simpleTest(String name) async {
  final fileName = {
    'common_mark': 'tool/common_mark_tests.json',
    'gfm': 'tool/gfm_tests.json'
  }[name];

  final url = {
    'common_mark': 'https://spec.commonmark.org/0.30',
    'gfm': 'https://github.github.com/gfm'
  }[name];

  final rootDir = await markdownPackageRoot;
  final file = File('$rootDir/$fileName');
  final json = file.readAsStringSync();
  final testCases = List<Map<String, dynamic>>.from(jsonDecode(json) as List);

  for (final testCase in testCases) {
    final description = '$url/#example-${testCase['example']}';
    test(description, () {
      final input = testCase['markdown'] as String;
      final output = markdownToMarkdown(input);

      expect(output, input);
    });
  }
}

Future<void> strictTest(String name) async {
  final rootDir = await markdownPackageRoot;
  final directory = p.joinAll([rootDir, 'test', name]);
  final entries = Directory(directory).listSync(followLinks: false);
  for (final entry in entries) {
    if (!entry.path.endsWith('json')) {
      continue;
    }
    final testCases = List<Map<String, dynamic>>.from(
      jsonDecode(File(entry.path).readAsStringSync()) as List,
    );
    for (final testCase in testCases) {
      test('${testCase['description']}', () {
        final result = Markdown()
            .parse(testCase['markdown'] as String)
            .map((e) => e.toMap())
            .toList();

        expect(result, testCase['expected']);
      });
    }
  }
}
