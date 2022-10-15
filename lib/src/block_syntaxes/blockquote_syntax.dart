// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../charcode.dart';
import '../extensions.dart';
import '../line.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';
import 'indented_code_block_syntax.dart';
import 'paragraph_syntax.dart';

/// Parses email-style blockquotes: `> quote`.
class BlockquoteSyntax extends BlockSyntax {
  @override
  RegExp get pattern => blockquotePattern;

  const BlockquoteSyntax();

  BlockSyntaxChildSource parseChildLines(BlockParser parser) {
    // Grab all of the lines that form the blockquote, stripping off the ">".
    final childLines = <Line>[];
    final markers = <SourceSpan>[];

    var lazyEnding = false;
    while (!parser.isDone) {
      final currentLine = parser.current;
      final match = currentLine.firstMatch(pattern);
      if (match != null) {
        int markerEnd;
        var isTabIndentation = false;
        // A block quote marker consists of a `>` together with a optional
        // following space of indentation, see
        // https://spec.commonmark.org/0.30/#block-quote-marker.
        final markerStart = match.match.indexOf('>');
        if (currentLine.content.length > 1) {
          final nextChar = currentLine.content.text.codeUnitAt(markerStart + 1);
          isTabIndentation = nextChar == $tab;
          final hasSpace = isTabIndentation || nextChar == $space;
          markerEnd = markerStart + (hasSpace ? 2 : 1);
        } else {
          markerEnd = markerStart + 1;
        }

        markers.add(currentLine.content.subspan(markerStart, markerStart + 1));

        childLines.add(Line(
          currentLine.content.subspan(markerEnd),
          lineEnding: currentLine.lineEnding,
          tabRemaining: isTabIndentation ? 2 : null,
        ));

        parser.advance();
        lazyEnding = false;
        continue;
      }

      // A paragraph continuation is OK. This is content that cannot be parsed
      // as any other syntax except Paragraph, and it doesn't match the bar in
      // a Setext header.
      // Because indented code blocks cannot interrupt paragraphs, a line
      // matched IndentedCodeBlockSyntax is also paragraph continuation text.
      final otherMatched =
          parser.blockSyntaxes.firstWhere((s) => s.canParse(parser));
      if ((otherMatched is ParagraphSyntax &&
              childLines.last.content.length > 0 &&
              !childLines.last.hasMatch(codeFencePattern)) ||
          (!childLines.last.hasMatch(indentPattern) &&
              otherMatched is IndentedCodeBlockSyntax)) {
        childLines.add(parser.current);
        lazyEnding = true;
        parser.advance();
      } else {
        break;
      }
    }

    return BlockSyntaxChildSource(
      markers: markers,
      lines: childLines,
      lazyEnding: lazyEnding,
    );
  }

  @override
  BlockElement parse(BlockParser parser) {
    final childSource = parseChildLines(parser);

    // Recursively parse the contents of the blockquote.
    final children = BlockParser(
      childSource.lines,
      parser.document,
    ).parseLines(
      // The setext heading underline cannot be a lazy continuation line in a
      // list item or block quote.
      // https://github.github.com/gfm/#example-62
      // https://github.github.com/gfm/#example-63
      // https://github.github.com/gfm/#example-64
      disabledSetextHeading: childSource.lazyEnding,
      fromSyntax: this,
    );

    return BlockElement(
      'blockquote',
      children: children,
      markers: childSource.markers,
    );
  }
}
