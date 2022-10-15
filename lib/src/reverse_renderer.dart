// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import 'ast.dart';
import 'markdown.dart';
import 'patterns.dart';
import 'syntax.dart';

/// Converts the given string to AST and renders AST to given string itself.
String markdownToMarkdown(
  String markdown, {
  Iterable<Syntax> extensions = const [],
  Resolver? linkResolver,
  Resolver? imageLinkResolver,
  bool enableTaskList = false,
  bool encodeHtml = true,
}) {
  final nodes = Markdown(
    extensions: extensions,
    linkResolver: linkResolver,
    imageLinkResolver: imageLinkResolver,
    enableTaskList: enableTaskList,
  ).parse(markdown);

  return ReverseRenderer(markdown).render(nodes);
}

class ReverseRenderer implements NodeVisitor {
  String _markdown;

  ReverseRenderer(String markdown)
      : _markdown =
            markdown.replaceAll(RegExp('[^$whitespaceCharacters]'), ' ');

  String render(List<Node> nodes) {
    for (final node in nodes) {
      node.accept(this);
    }
    return _markdown;
  }

  @override
  void visitText(Text text) {
    _write(text);
  }

  @override
  bool visitElementBefore(Element element) => true;

  @override
  void visitElementAfter(Element element) {
    element.markers.forEach(_write);
  }

  void _write(SourceSpan span) {
    _markdown = _markdown.replaceRange(
      span.start.offset,
      span.end.offset,
      span.text,
    );
  }
}
