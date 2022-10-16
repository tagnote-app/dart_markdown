// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../line.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

/// Parses lines fenced by `>>>` to blockquotes
class FencedBlockquoteSyntax extends BlockSyntax {
  const FencedBlockquoteSyntax();

  @override
  RegExp get pattern => blockquoteFencePattern;

  BlockSyntaxChildSource parseChildLines(BlockParser parser) {
    final lines = <Line>[];
    final markders = [parser.current.content];

    parser.advance();

    while (!parser.isDone) {
      final match = parser.current.hasMatch(pattern);
      if (!match) {
        lines.add(parser.current);
        parser.advance();
      } else {
        markders.add(parser.current.content);
        parser.advance();
        break;
      }
    }

    return BlockSyntaxChildSource(
      lines: lines,
      markers: markders,
    );
  }

  @override
  BlockElement? parse(BlockParser parser) {
    final childSource = parseChildLines(parser);

    // Recursively parse the contents of the blockquote.
    final children = BlockParser(
      childSource.lines,
      parser.document,
    ).parseLines();

    final markers = childSource.markers;

    return BlockElement(
      'fencedBlockquote',
      children: children,
      markers: markers,
      start: markers.first.start,
      end: markers.length > 1
          ? markers.last.end
          : (children.isNotEmpty ? children.last.end : markers.single.end),
    );
  }
}
