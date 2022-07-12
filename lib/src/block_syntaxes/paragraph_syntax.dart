// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../line.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';
import 'setext_heading_syntax.dart';

/// Parses paragraphs of regular text.
class ParagraphSyntax extends BlockSyntax {
  @override
  RegExp get pattern => dummyPattern;

  @override
  bool canInterrupt(BlockParser parser) => false;

  const ParagraphSyntax({
    bool disable = false,
  }) : _disabled = disable;

  final bool _disabled;

  @override
  bool canParse(BlockParser parser) => true;

  @override
  Node? parse(BlockParser parser) {
    final List<Line> lines = [parser.current];
    parser.advance();

    var hitSetextHeading = false;

    // Eat until we hit something that ends a paragraph.
    while (!parser.isDone) {
      final syntax = interruptedBy(parser);
      if (syntax != null) {
        hitSetextHeading = syntax is SetextHeadingSyntax;
        break;
      }
      lines.add(parser.current);
      parser.advance();
    }

    // It is not a paragraph, but a setext heading.
    if (hitSetextHeading) {
      return null;
    }

    final content = lines.toNodes(
      (span) => UnparsedContent.fromSpan(span),
      trimTrailing: true,
      trimLeft: true,
      popLineEnding: true,
    );

    if (!_disabled) {
      return Element(
        'paragraph',
        children: content.nodes,
        // Add an empty modifiable markers here, in case a paragraph has
        // `_backslashEscape` children.
        markers: [],
      );
    }

    if (content.nodes.isEmpty) {
      return null;
    }
    assert(content.nodes.length == 1);
    return content.nodes.first;
  }
}
