// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../charcode.dart';
import '../helpers/extensions.dart';
import '../parsers/inline_parser.dart';
import '../syntax.dart';

/// Matches backtick-enclosed inline code blocks.
class CodeSpanSyntax extends InlineSyntax {
  // This pattern matches:
  //
  // * a string of backticks (not followed by any more), followed by
  // * a non-greedy string of anything, including newlines, ending with anything
  //   except a backtick, followed by
  // * a string of backticks the same length as the first, not followed by any
  //   more.
  //
  // This conforms to the delimiters of inline code, both in Markdown.pl, and
  // CommonMark.
  static const _pattern = r'(`+(?!`))(?:.|\n)*?[^`](\1)(?!`)';

  CodeSpanSyntax()
      : super(RegExp(_pattern, multiLine: true), startCharacter: $backquote);

  @override
  Match? tryMatch(InlineParser parser, [int? start]) {
    if (parser.position > 0 &&
        parser.charAt(parser.position - 1) == $backquote) {
      // Not really a match! We can't just sneak past one backtick to try the
      // next character. An example of this situation would be:
      //
      //     before ``` and `` after.
      //             ^--parser.pos
      return null;
    }

    return super.tryMatch(parser, start);
  }

  @override
  InlineElement parse(InlineParser parser, Match match) {
    final markerLength = match[1]!.length;
    final contentLength = match.match.length - markerLength * 2;
    final markers = parser.consumeBy(markerLength);
    final contentSpans = <SourceSpan>[];

    _parseAndStrip(
      parser,
      contentLength: contentLength,
      contentSpans: contentSpans,
    );

    if (contentSpans.isEmpty) {
      contentSpans.addAll(parser.consumeBy(contentLength));
    }

    markers.add(parser.consumeBy(markerLength).first);

    return InlineElement(
      'codeSpan',
      children: contentSpans
          .map((span) => Text.fromSpan(span, lineEndingToWhitespace: true))
          .toList(),
      markers: markers,
      start: markers.first.start,
      end: markers.last.end,
    );
  }

  void _parseAndStrip(
    InlineParser parser, {
    required int contentLength,
    required List<SourceSpan> contentSpans,
  }) {
    final contentText = parser.substring(
      parser.position,
      parser.position + contentLength,
    );

    // No stripping occurs if the code span contains only spaces:
    // https://spec.commonmark.org/0.30/#example-334.
    if (contentText.trim().isEmpty) {
      return;
    }

    // Only spaces, and not unicode whitespace in general, are stripped in this
    // way, see https://spec.commonmark.org/0.30/#example-333.
    final startWithSpace =
        contentText.startsWith(' ') || contentText.startsWith('\n');
    final endsWithSpace =
        contentText.endsWith(' ') || contentText.endsWith('\n');

    // The stripping only happens if the space is on both sides of the string:
    // https://spec.commonmark.org/0.30/#example-332.
    if (!startWithSpace || !endsWithSpace) {
      return;
    }

    parser.advance();
    contentSpans.addAll(parser.consumeBy(contentLength - 2));
    parser.advance();
  }
}
