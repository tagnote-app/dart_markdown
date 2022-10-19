// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../helpers/extensions.dart';
import '../helpers/util.dart';
import '../line.dart';
import '../markdown.dart';
import '../parsers/block_parser.dart';
import '../parsers/link_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

class LinkReferenceDefinitionSyntax extends BlockSyntax {
  @override
  RegExp get pattern => linkReferenceDefinitionPattern;

  @override
  bool canInterrupt(BlockParser parser) => false;

  const LinkReferenceDefinitionSyntax();

  @override
  BlockElement? parse(BlockParser parser) {
    final position = parser.position;
    final lines = <Line>[parser.current];
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

  BlockElement? _parseLinkReferenceDefinition(
    List<Line> lines,
    BlockParser parser,
  ) {
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

    final labelChildren = label.map(Text.fromSpan).toList();
    final destinationChildren = destination.map(Text.fromSpan).toList();
    final titleChildren = title?.map(Text.fromSpan).toList();
    final definitionLabel = InlineElement(
      'linkReferenceDefinitionLabel',
      children: labelChildren,
      start: labelChildren.first.start,
      end: labelChildren.last.end,
    );
    final definitionDestination = InlineElement(
      'linkReferenceDefinitionDestination',
      children: destinationChildren,
      start: destinationChildren.isNotEmpty
          ? destinationChildren.first.start
          : definitionLabel.end,
      end: destinationChildren.isNotEmpty
          ? destinationChildren.last.end
          : definitionLabel.end,
    );

    final children = [
      definitionLabel,
      definitionDestination,
      if (titleChildren != null)
        InlineElement(
          'linkReferenceDefinitionTitle',
          children: titleChildren,
          start: titleChildren.first.start,
          end: titleChildren.last.end,
        ),
    ];

    return BlockElement(
      'linkReferenceDefinition',
      markers: linkParser.markers,
      children: children,
      start: linkParser.markers.first.start,
      end: [children.last.end, linkParser.markers.last.end].largest(),
    );
  }
}
