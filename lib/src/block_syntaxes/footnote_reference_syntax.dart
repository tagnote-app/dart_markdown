// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../line.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

// See
// https://github.com/tagnote-app/dart_markdown/wiki/footnote-reference-specification
class FootnoteReferenceSyntax extends BlockSyntax {
  @override
  RegExp get pattern => footnoteReferencePattern;

  @override
  bool canInterrupt(BlockParser parser) => false;

  @override
  bool canParse(BlockParser parser) {
    if (parser.parentSyntax != null) {
      return false;
    }

    return parser.current.hasMatch(pattern);
  }

  final bool enableParagraph;

  const FootnoteReferenceSyntax({
    this.enableParagraph = true,
  });

  @override
  BlockElement? parse(BlockParser parser) {
    final position = parser.position;
    final matchedLine = parser.current;
    final match = matchedLine.firstMatch(pattern)!;
    final lines = _parseLines(parser, match);

    if (lines.isEmpty) {
      parser.setLine(position);
      return null;
    }

    // Parse the marker
    final indention = match[1]!.length;
    final labelString = match[2]!;
    final marker = matchedLine.content.subspan(
      indention,
      indention + labelString.length + 4,
    );

    final children = _parseChildren(lines);
    final element = BlockElement(
      'footnoteReference',
      markers: [marker],
      attributes: {'label': labelString},
      children: _parseChildren(lines),
      start: marker.start,
      end: children.last.end,
    );
    parser.document.addFootnoteReference(labelString, element);
    return element;
  }

  List<Line> _parseLines(BlockParser parser, Match match) {
    // `matchedLength` includes leading whitespaces, a marker sequence and
    // an optional whitespace.
    final matchedLength = match[0]!.length;
    final lines = [
      Line(
        // removes the matched content from the first line.
        parser.current.content.subspan(matchedLength),
        lineEnding: parser.current.lineEnding,
      ),
    ];
    parser.advance();

    // The first line can be a blank line.
    var hitBlankLine = lines.first.content.text.trim().isEmpty ? 1 : 0;
    while (!parser.isDone) {
      // Hit another footnote reference.
      if (parser.current.hasMatch(pattern)) {
        break;
      }
      // An indention is required if follows a blank line.
      if (hitBlankLine == 1 &&
          !parser.current.hasMatch(RegExp('^(?:\t|[ ]{2,})'))) {
        break;
      }

      if (!parser.current.isBlankLine) {
        hitBlankLine = 0;
      } else if (++hitBlankLine == 2) {
        // Only one blank line is allowed.
        break;
      }
      lines.add(parser.current);
      parser.advance();
    }

    // Remove the first blank line.
    if (lines.first.isBlankLine) {
      lines.removeAt(0);
    }

    if (lines.isEmpty) {
      return [];
    }

    // Remove the last blank line.
    if (lines.last.isBlankLine) {
      lines.removeLast();
    }

    return lines;
  }

  List<Node> _parseChildren(List<Line> lines) {
    if (!enableParagraph) {
      return _toUnparsedContent(lines);
    }

    final paragraphs = <BlockElement>[];
    final paragraphLines = <Line>[];

    void addToParagraphs() {
      if (paragraphLines.isEmpty) {
        return;
      }

      final children = _toUnparsedContent(paragraphLines);
      paragraphs.add(BlockElement(
        'paragraph',
        children: children,
        start: children.first.start,
        end: children.last.end,
      ));

      paragraphLines.clear();
    }

    for (final line in lines) {
      if (line.isBlankLine) {
        addToParagraphs();
      } else {
        paragraphLines.add(line);
      }
    }
    addToParagraphs();

    if (paragraphs.length == 1) {
      return paragraphs.single.children;
    }

    return paragraphs;
  }

  List<Node> _toUnparsedContent(List<Line> lines) => lines
      .toNodes(
        UnparsedContent.fromSpan,
        trimLeft: true,
        trimTrailing: true,
        popLineEnding: true,
      )
      .nodes;
}
