// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import '../ast.dart';

/// The return data of [whichElement] api.
class WhichElement {
  const WhichElement({
    required this.path,
    required this.text,
    required this.marker,
  });

  final List<Element> path;
  final Text? text;
  final SourceSpan? marker;

  List<String> get pathTypes => path.map((e) => e.type).toList();
}

bool _canMatchElement(int offset, Element element, String text) {
  if (offset < element.start.offset) {
    return false;
  }

  final end = element.end.offset;
  if (element is InlineElement) {
    return offset < end;
  }

  if (offset >= end && offset < text.length) {
    final remainingText = text.substring(end, offset + 1);
    if (!remainingText.contains('\n')) {
      return true;
    }
  }

  return offset < end;
}

SourceSpan? _matchSourceSpan(int offset, SourceSpan span) {
  final start = span.start.offset;
  final end = span.end.offset;
  if (offset < start) {
    return null;
  }

  if (offset < end) {
    return span;
  }
  return null;
}

extension WhichElementExtension on List<Node> {
  /// Seeks the element at the given [offset].\
  /// [text] is the original Markdown string.
  WhichElement whichElement(int offset, String text) {
    final path = <Element>[];
    Text? textNode;
    SourceSpan? matchedMarker;

    void loop(List<Node> nodes) {
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];

        if (node is Element) {
          for (final marker in node.markers) {
            final hitSpan = _matchSourceSpan(offset, marker);
            if (hitSpan != null) {
              matchedMarker = hitSpan;
            }
          }

          final match = _canMatchElement(offset, node, text);
          if (match) {
            path.add(node);
            loop(node.children);
          }
        } else if (node is Text) {
          final hitSpan = _matchSourceSpan(offset, node);
          if (hitSpan != null) {
            textNode = hitSpan as Text;
          }
        }
      }
    }

    loop(this);

    return WhichElement(path: path, text: textNode, marker: matchedMarker);
  }
}
