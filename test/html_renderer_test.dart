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
}
