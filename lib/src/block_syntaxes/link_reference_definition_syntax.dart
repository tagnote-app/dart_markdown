// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../document.dart';
import '../line.dart';
import '../parsers/block_parser.dart';
import '../parsers/link_parser.dart';
import '../patterns.dart';
import '../syntax.dart';
import '../util.dart';

class LinkReferenceDefinitionSyntax extends BlockSyntax {
  @override
  RegExp get pattern => linkReferenceDefinitionPattern;

  @override
  bool canInterrupt(BlockParser parser) => false;

  const LinkReferenceDefinitionSyntax();

  @override
  Node? parse(BlockParser parser) {
    final position = parser.position;
    final List<Line> lines = [parser.current];
    parser.advance();

    while (!shouldEnd(parser)) {
      lines.add(parser.current);
      parser.advance();
    }

    final defNode = _parseLinkReferenceDefinition(lines, parser);
    if (defNode == null) {
      parser.setLine(position);
      return null;
    }

    return defNode;
  }

  Node? _parseLinkReferenceDefinition(List<Line> lines, BlockParser parser) {
    final linkParser = LinkParser(lines.toSourceSpans())..parseDefinition();
    if (!linkParser.valid) {
      return null;
    }

    final label = linkParser.label;
    final destination = linkParser.destination;
    final title = linkParser.title;
    // Set the parsing position back to where the link reference definition
    // ends, so other syntax are able to consume the rest.
    final line = title == null || title.isEmpty
        ? (destination.isNotEmpty
            ? destination.last.end.line
            : label.last.end.line)
        : title.last.end.line;
    parser.setLine(line + 1);

    final labelString = normalizeLinkLabel(label.map((e) => e.text).join());

    parser.document.linkReferences.putIfAbsent(
      labelString,
      () => LinkReference(
        labelString,
        linkParser.formatted.destination,
        linkParser.formatted.title,
      ),
    );

    return Element(
      'linkReferenceDefinition',
      markers: linkParser.markers,
      children: [
        Element(
          'linkReferenceDefinitionLabel',
          children: label.map((span) => Text.fromSpan(span)).toList(),
        ),
        Element(
          'linkReferenceDefinitionDestination',
          children: destination.map((span) => Text.fromSpan(span)).toList(),
        ),
        if (title != null)
          Element(
            'linkReferenceDefinitionTitle',
            children: title.map((span) => Text.fromSpan(span)).toList(),
          ),
      ],
    );
  }
}
