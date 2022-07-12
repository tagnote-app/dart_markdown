// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_markdown/dart_markdown.dart';
import 'package:dart_markdown/src/util.dart';
import 'package:test/test.dart';

void main() {
  group('encodeHtml', () {
    test('encodeHtml prevents less than and ampersand escaping', () {
      final result = _toSingleHtmlElement(
        '< &',
        Document(),
        encodeHtml: false,
      ).children!;
      expect(result, hasLength(1));
      expect(
        result[0],
        const TypeMatcher<HtmlText>().having(
          (e) => e.text,
          'text',
          equals('< &'),
        ),
      );
    });
  });
  group('with encodeHtml enabled', () {
    final document = Document();

    test('encodes HTML in an inline code snippet', () {
      final codeSnippet = _toSingleHtmlElement(
        '``<p>Hello <em>Markdown</em></p>``',
        document,
        encodeHtml: true,
      );
      expect(
        codeSnippet.textContent,
        equals('&lt;p&gt;Hello &lt;em&gt;Markdown&lt;/em&gt;&lt;/p&gt;'),
      );
    });

    test('encodes HTML in a fenced code block', () {
      final codeBlock = _toSingleHtmlElement(
        '```\n<p>Hello <em>Markdown</em></p>\n```\n',
        document,
        encodeHtml: true,
      );
      expect(
        codeBlock.textContent,
        equals('&lt;p&gt;Hello &lt;em&gt;Markdown&lt;/em&gt;&lt;/p&gt;\n'),
      );
    });

    test('encodes HTML in an indented code block', () {
      final codeBlock = _toSingleHtmlElement(
        '    <p>Hello <em>Markdown</em></p>\n',
        document,
        encodeHtml: true,
      );
      expect(
        codeBlock.textContent,
        equals('&lt;p&gt;Hello &lt;em&gt;Markdown&lt;/em&gt;&lt;/p&gt;\n'),
      );
    });

    test('encodeHtml spaces are preserved in text', () {
      // Example to get a <p> tag rendered before a text node.
      final content = 'Sample\n\n<pre>\n A\n B\n</pre>';
      final lines = stringToLines(content);
      final nodes = BlockParser(lines, document).parseLines();
      final htmlNodes = HtmlTransformer(encodeHtml: true).transform(nodes);
      final result = HtmlRenderer().render(htmlNodes);
      expect(result, '<p></p>\n<pre>\n A\n B\n</pre>');
    });

    test('encode double quotes, greater than, and less than when escaped', () {
      final result = _toSingleHtmlElement(
        r'\>\"\< Hello',
        document,
        encodeHtml: true,
      ).children!;
      expect(result, hasLength(4));
      expect(
        result.map((e) => (e as HtmlText).text).join(),
        '&gt;&quot;&lt; Hello',
      );
    });
  });

  group('with encodeHtml disabled', () {
    final document = Document();

    test('leaves HTML alone, in a code snippet', () {
      final result = _toSingleHtmlElement(
        '```<p>Hello <em>Markdown</em></p>```',
        document,
        encodeHtml: false,
      ).children!;

      final codeSnippet = result.single as HtmlElement;
      expect(
        codeSnippet.textContent,
        equals('<p>Hello <em>Markdown</em></p>'),
      );
    });

    test('leaves HTML alone, in a fenced code block', () {
      final codeBlock = _toSingleHtmlElement(
        '```\n<p>Hello <em>Markdown</em></p>\n```\n',
        document,
        encodeHtml: false,
      );
      expect(
        codeBlock.textContent,
        equals('<p>Hello <em>Markdown</em></p>\n'),
      );
    });

    test('leaves HTML alone, in an indented code block', () {
      final codeBlock = _toSingleHtmlElement(
        '    <p>Hello <em>Markdown</em></p>\n',
        document,
        encodeHtml: false,
      );
      expect(
        codeBlock.textContent,
        equals('<p>Hello <em>Markdown</em></p>\n'),
      );
    });

    test('leave double quotes, greater than, and less than when escaped', () {
      final result = _toSingleHtmlElement(
        r'\>\"\< Hello',
        document,
        encodeHtml: false,
      ).children!;
      expect(result, hasLength(4));
      expect(
        result.map((e) => (e as HtmlText).text).join(),
        '>"< Hello',
      );
    });
  });
}

HtmlElement _toSingleHtmlElement(
  String markdown,
  Document document, {
  required bool encodeHtml,
}) =>
    (HtmlTransformer(encodeHtml: encodeHtml)
        .transform(document.parseLines(markdown))
        .single as HtmlElement);
