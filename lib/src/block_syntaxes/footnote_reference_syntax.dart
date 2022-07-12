// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../extensions.dart';
import '../line.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

// See https://www.markdownguide.org/extended-syntax/#footnotes

// A footnote definition consists of a label, optionally preceded by up to three
// spaces of indentation, followed by a colon (:), optional spaces or tabs
// (including up to one line ending), followed by a note content.
//
// A footnote reference can be interrupted by two blank lines or another
// footnote reference.
//
// A footnote reference can contain any elements excpet footnote references.
//
// A footnote definition can not be nested in any other elements other than
// the paragraph.
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

  const FootnoteReferenceSyntax();

  @override
  Node? parse(BlockParser parser) {
    final position = parser.position;
    final lines = <Line>[parser.current];
    parser.advance();

    int hitBlankLine = 0;
    while (!parser.isDone) {
      if (parser.current.hasMatch(footnoteReferencePattern)) {
        break;
      }
      if (parser.current.isBlankLine) {
        hitBlankLine++;
        if (hitBlankLine == 2) {
          break;
        }
      } else {
        hitBlankLine = 0;
      }
      lines.add(parser.current);
      parser.advance();
    }

    // Remove the last blank line.
    if (lines.last.isBlankLine) {
      lines.removeLast();
    }

    final markers = <SourceSpan>[];
    final match = lines.first.firstMatch(footnoteReferencePattern);

    // `matchedLength` includes the preceding whitespace, a marker sequence and
    // an optional whitespace.
    final matchedLength = match![0]!.length;

    if (lines.length == 1 &&
        lines.first.content.text.trimRight().length <= matchedLength) {
      parser.setLine(position);
      return null;
    }

    final indention = match[1]!.length;
    final labelString = match[2]!;
    markers.add(lines.first.content.subspan(
      indention,
      indention + labelString.length + 4,
    ));

    lines[0] = Line(
      lines[0].content.subspan(matchedLength),
      lineEnding: lines[0].lineEnding,
    );

    // Recursively parse the content.
    final children = BlockParser(lines, parser.document).parseLines(
      fromSyntax: this,
    );

    final element = Element(
      'footnoteReference',
      markers: markers.concatWhilePossible(),
      attributes: {'label': labelString},
      children: children,
    );
    parser.document.addFootnoteReference(labelString, element);
    return element;
  }
}
