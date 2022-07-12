// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_markdown/dart_markdown.dart';
import 'package:dart_markdown/src/block_syntaxes/thematic_break_syntax.dart';
import 'package:dart_markdown/src/inline_syntaxes/emphasis_syntax.dart';
import 'package:test/test.dart';

void main() {
  group('test enable syntaxes options', () {
    const text = '# Hello **Markdown<em>!</em>**\n***';

    test('with no syntaxes', () {
      final result = markdownToHtml(
        text,
        enableAtxHeading: false,
        enableBlankLine: false,
        enableHeadingId: false,
        enableBlockquote: false,
        enableIndentedCodeBlock: false,
        enableFencedBlockquote: false,
        enableFencedCodeBlock: false,
        enableList: false,
        enableParagraph: false,
        enableSetextHeading: false,
        enableTable: false,
        enableThematicBreak: false,
        enableAutolinkExtension: false,
        enableAutolink: false,
        enableBackslashEscape: false,
        enableCodeSpan: false,
        enableEmoji: false,
        enableEmphasis: false,
        enableHardLineBreak: false,
        enableImage: false,
        enableLink: false,
        enableRawHtml: false,
        enableSoftLineBreak: false,
        enableStrikethrough: false,
        enableHtmlBlock: false,
        encodeHtml: false,
      );
      expect(result, equals('# Hello **Markdown<em>!</em>**\n***'));
    });

    test('with no default syntaxes but with custom syntaxes', () {
      final result = markdownToHtml(
        text,
        enableAtxHeading: false,
        enableBlankLine: false,
        enableHeadingId: false,
        enableBlockquote: false,
        enableIndentedCodeBlock: false,
        enableFencedBlockquote: false,
        enableFencedCodeBlock: false,
        enableList: false,
        enableParagraph: false,
        enableSetextHeading: false,
        enableTable: false,
        enableThematicBreak: false,
        enableAutolinkExtension: false,
        enableAutolink: false,
        enableBackslashEscape: false,
        enableCodeSpan: false,
        enableEmoji: false,
        enableEmphasis: false,
        enableHardLineBreak: false,
        enableImage: false,
        enableLink: false,
        enableRawHtml: false,
        enableSoftLineBreak: false,
        enableStrikethrough: false,
        enableHtmlBlock: false,
        encodeHtml: false,
        extensions: [
          const ThematicBreakSyntax(),
          EmphasisSyntax.asterisk(),
        ],
      );

      expect(
        result,
        equals('# Hello <strong>Markdown<em>!</em></strong>\n<hr />'),
      );
    });

    test('with only block syntaxes', () {
      final result = markdownToHtml(
        text,
        enableAutolinkExtension: false,
        enableAutolink: false,
        enableBackslashEscape: false,
        enableCodeSpan: false,
        enableEmoji: false,
        enableEmphasis: false,
        enableHardLineBreak: false,
        enableImage: false,
        enableLink: false,
        enableRawHtml: false,
        enableSoftLineBreak: false,
        enableStrikethrough: false,
        encodeHtml: false,
      );

      expect(
        result,
        equals('<h1>Hello **Markdown<em>!</em>**</h1>\n<hr />'),
      );
    });

    test('with only default inline syntaxes', () {
      final result = markdownToHtml(
        text,
        enableAtxHeading: false,
        enableBlankLine: false,
        enableHeadingId: false,
        enableBlockquote: false,
        enableIndentedCodeBlock: false,
        enableFencedBlockquote: false,
        enableFencedCodeBlock: false,
        enableList: false,
        enableParagraph: false,
        enableSetextHeading: false,
        enableTable: false,
        enableThematicBreak: false,
        enableHtmlBlock: false,
        encodeHtml: false,
      );

      expect(
        result,
        equals('# Hello <strong>Markdown<em>!</em></strong>\n***'),
      );
    });

    test('with no default syntaxes but with encodeHtml enabled', () {
      final result = markdownToHtml(
        text,
        enableAtxHeading: false,
        enableBlankLine: false,
        enableHeadingId: false,
        enableBlockquote: false,
        enableIndentedCodeBlock: false,
        enableFencedBlockquote: false,
        enableFencedCodeBlock: false,
        enableList: false,
        enableParagraph: false,
        enableSetextHeading: false,
        enableTable: false,
        enableThematicBreak: false,
        enableAutolinkExtension: false,
        enableAutolink: false,
        enableBackslashEscape: false,
        enableCodeSpan: false,
        enableEmoji: false,
        enableEmphasis: false,
        enableHardLineBreak: false,
        enableImage: false,
        enableLink: false,
        enableRawHtml: false,
        enableSoftLineBreak: false,
        enableStrikethrough: false,
        enableHtmlBlock: false,
        encodeHtml: true,
      );

      expect(
        result,
        equals('# Hello **Markdown&lt;em&gt;!&lt;/em&gt;**\n***'),
      );
    });
  });

  group('test task list', () {
    group('not a task list item', () {
      test('no whitespace after "]"', () {
        final result = markdownToHtml(
          '- [ ]Foo',
          enableTaskList: true,
        );
        expect(result, '<ul>\n<li>[ ]Foo</li>\n</ul>');
      });

      test('no whitespace between "[" and "]"', () {
        final result = markdownToHtml(
          '- [] Foo',
          enableTaskList: true,
        );
        expect(result, '<ul>\n<li>[] Foo</li>\n</ul>');
      });

      test('invalid check symbol', () {
        final result = markdownToHtml(
          '- [Y] Foo',
          enableTaskList: true,
        );
        expect(result, '<ul>\n<li>[Y] Foo</li>\n</ul>');
      });
    });
    group('valid task list item', () {
      test('unchecked status', () {
        final result = markdownToHtml(
          '- [ ] Foo',
          enableTaskList: true,
        );
        expect(result, '<ul>\n<li><input type="checkbox" /> Foo</li>\n</ul>');
      });
      test('checked status', () {
        final result = markdownToHtml(
          '- [X] Foo',
          enableTaskList: true,
        );
        expect(
          result,
          '<ul>\n<li><input type="checkbox" checked="" /> Foo</li>\n</ul>',
        );
      });

      test('has a leading blank line', () {
        final result = markdownToHtml(
          '-\n  [ ] Foo',
          enableTaskList: true,
        );
        expect(result, '<ul>\n<li><input type="checkbox" /> Foo</li>\n</ul>');
      });

      test('nested', () {
        final result = markdownToHtml(
          '''
- [x] foo
  - [ ] bar
  - [x] baz
- [ ] bim
''',
          enableTaskList: true,
        );
        expect(result, '''
<ul>
<li><input type="checkbox" checked="" /> foo
<ul>
<li><input type="checkbox" /> bar</li>
<li><input type="checkbox" checked="" /> baz</li>
</ul>
</li>
<li><input type="checkbox" /> bim</li>
</ul>''');
      });

      test('task list items mixed with regular list item', () {
        final result = markdownToHtml(
          '''
+ [x] foo
+ bar
+ [ ] baz
''',
          enableTaskList: true,
        );
        expect(result, '''
<ul>
<li><input type="checkbox" checked="" /> foo</li>
<li>bar</li>
<li><input type="checkbox" /> baz</li>
</ul>''');
      });
    });
  });
}
