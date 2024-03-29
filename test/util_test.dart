// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_markdown/src/helpers/util.dart';
import 'package:test/test.dart';

void main() {
  group('for stringToLines()', () {
    test('a single line without a line ending', () {
      const text = 'Foo';
      final lines = stringToLines(text);
      expect(lines.map((e) => e.toMap()), [
        {
          'text': 'Foo',
          'content': {
            'start': {'line': 0, 'column': 0, 'offset': 0},
            'end': {'line': 0, 'column': 3, 'offset': 3},
            'text': 'Foo'
          },
          'lineEnding': null,
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 0, 'column': 3, 'offset': 3},
          'isBlankLine': false,
          'tabRemaining': null,
        }
      ]);
    });

    test('a single line with a line ending', () {
      const text = 'Foo\n';
      final lines = stringToLines(text);
      expect(lines.map((e) => e.toMap()), [
        {
          'text': 'Foo\n',
          'content': {
            'start': {'line': 0, 'column': 0, 'offset': 0},
            'end': {'line': 0, 'column': 3, 'offset': 3},
            'text': 'Foo'
          },
          'lineEnding': {
            'start': {'line': 0, 'column': 3, 'offset': 3},
            'end': {'line': 1, 'column': 0, 'offset': 4},
            'text': '\n'
          },
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 1, 'column': 0, 'offset': 4},
          'isBlankLine': false,
          'tabRemaining': null,
        },
      ]);
    });
    test('multiple lines with a blank line in between', () {
      const text = 'Foo\r\n\nBar';
      final lines = stringToLines(text);
      expect(lines.map((e) => e.toMap()), [
        {
          'text': 'Foo\r\n',
          'content': {
            'start': {'line': 0, 'column': 0, 'offset': 0},
            'end': {'line': 0, 'column': 3, 'offset': 3},
            'text': 'Foo'
          },
          'lineEnding': {
            'start': {'line': 0, 'column': 3, 'offset': 3},
            'end': {'line': 1, 'column': 0, 'offset': 5},
            'text': '\r\n'
          },
          'start': {'line': 0, 'column': 0, 'offset': 0},
          'end': {'line': 1, 'column': 0, 'offset': 5},
          'isBlankLine': false,
          'tabRemaining': null
        },
        {
          'text': '\n',
          'content': {
            'start': {'line': 1, 'column': 0, 'offset': 5},
            'end': {'line': 1, 'column': 0, 'offset': 5},
            'text': ''
          },
          'lineEnding': {
            'start': {'line': 1, 'column': 0, 'offset': 5},
            'end': {'line': 2, 'column': 0, 'offset': 6},
            'text': '\n'
          },
          'start': {'line': 1, 'column': 0, 'offset': 5},
          'end': {'line': 2, 'column': 0, 'offset': 6},
          'isBlankLine': true,
          'tabRemaining': null
        },
        {
          'text': 'Bar',
          'content': {
            'start': {'line': 2, 'column': 0, 'offset': 6},
            'end': {'line': 2, 'column': 3, 'offset': 9},
            'text': 'Bar'
          },
          'lineEnding': null,
          'start': {'line': 2, 'column': 0, 'offset': 6},
          'end': {'line': 2, 'column': 3, 'offset': 9},
          'isBlankLine': false,
          'tabRemaining': null
        }
      ]);
    });
  });
}
