// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import 'extensions.dart';

typedef Resolver = InlineObject? Function(String name, [String? title]);

/// Base class for Markdown AST item such as [Element] and [Text].
abstract class Node {
  String get textContent;

  void accept(NodeVisitor visitor);

  /// The start location of this node.
  SourceLocation get start;

  /// The end location of this node.
  SourceLocation get end;

  /// Outputs the attributes as a `Map`.
  Map<String, dynamic> toMap();
}

/// An AST node that can contain other nodes.
abstract class Element<T extends Node> implements Node {
  /// Such as `headline`
  final String type;

  final List<SourceSpan> markers;

  final List<T> children;
  final Map<String, String> attributes;
  final bool isBlock;

  @override
  String get textContent {
    return children.map((child) => child.textContent).join();
  }

  @override
  SourceLocation get start => [
        ...markers.map((e) => e.start),
        ...children.map((e) => e.start),
      ].smallest();

  @override
  SourceLocation get end => [
        ...markers.map((e) => e.end),
        ...children.map((e) => e.end),
      ].largest();

  const Element(
    this.type, {
    required this.isBlock,
    required this.markers,
    required this.children,
    required this.attributes,
  });

  @override
  void accept(NodeVisitor visitor) {
    if (visitor.visitElementBefore(this)) {
      if (children.isNotEmpty) {
        for (final child in children) {
          child.accept(visitor);
        }
      }
      visitor.visitElementAfter(this);
    }
  }

  @override
  Map<String, dynamic> toMap({
    bool showNull = false,
    bool showEmpty = false,
    bool showRuntimeType = false,
  }) =>
      {
        if (showRuntimeType) 'runtimeType': runtimeType,
        'type': type,
        'start': start.toMap(),
        'end': end.toMap(),
        if (markers.isNotEmpty || showEmpty)
          'markers': markers.map((e) => e.toMap()).toList(),
        if (children.isNotEmpty || showEmpty)
          'children': children.map((e) => e.toMap()).toList(),
        if (attributes.isNotEmpty || showEmpty) 'attributes': attributes,
      };

  @override
  String toString() => toMap().toPrettyString();
}

/// A block element which should be created by [BlockParser].
class BlockElement extends Element {
  const BlockElement(
    super.type, {
    super.markers = const [],
    super.children = const [],
    super.attributes = const {},
  }) : super(isBlock: true);
}

/// A base type for [InlineElement] and [Text].
abstract class InlineObject implements Node {}

/// A inline element which should be created by [InlineParser].
class InlineElement extends Element<InlineObject> implements InlineObject {
  const InlineElement(
    super.type, {
    super.markers = const [],
    super.children = const [],
    super.attributes = const {},
  }) : super(isBlock: false);
}

/// A plain text element.
class Text extends SourceSpanBase implements InlineObject {
  /// How many spaces of a tab that remains after part of it has been consumed.
  // See: https://spec.commonmark.org/0.30/#example-6
  final int? _tabRemaining;

  /// If needs to convert line endings to whitespaces.
  // When it is a code span, line endings are treated like spaces, see
  // https://spec.commonmark.org/0.30/#example-335
  final bool _lineEndingToWhitespace;

  @override
  String get textContent {
    var result = text;
    if (_lineEndingToWhitespace) {
      result = text.replaceAll('\n', ' ');
    }
    if (_tabRemaining != null) {
      result = "${' ' * _tabRemaining!}$text";
    }
    return result;
  }

  @override
  void accept(NodeVisitor visitor) => visitor.visitText(this);

  Text(
    String text, {
    required SourceLocation start,
    required SourceLocation end,
    int? tabRemaining,
    bool lineEndingToWhitespace = false,
  })  : _tabRemaining = tabRemaining,
        _lineEndingToWhitespace = lineEndingToWhitespace,
        super(start, end, text);

  /// Instantiates a [Text] from [span].
  Text.fromSpan(
    SourceSpan span, {
    int? tabRemaining,
    bool lineEndingToWhitespace = false,
  })  : _tabRemaining = tabRemaining,
        _lineEndingToWhitespace = lineEndingToWhitespace,
        super(span.start, span.end, span.text);

  /// Converts [text] to the result which meets the CommonMark specification,
  /// includinug:
  ///
  /// 1. Escapes the characters (`<`), (`>`) and (`&`).
  /// 2. Set [escapesDoubleQuotes] to `true` to escape double quotes (`"`).
  /// 3. Set [decodeHtmlCharacter] to `true` to decode HTML entity and numeric
  ///    character references, for example decode `&#35` to `#`.
  String htmlText({
    bool escapesDoubleQuotes = true,
    bool decodeHtmlCharacter = true,
  }) =>
      textContent.toHtmlText(
        escapesDoubleQuotes: escapesDoubleQuotes,
        decodeHtmlCharacter: decodeHtmlCharacter,
      );

  Text subText(int start, [int? end]) => Text.fromSpan(subspan(start, end));

  /// Combines `this` and the adjacent [other].
  Text concat(SourceSpan other) =>
      Text('$text${other.text}', start: start, end: other.end);

  /// Instantiates a [Text] from `String` [text].
  ///
  /// **Warning:**
  /// This is an interface that facilitates the creation of [Text] by the end
  /// user. It shuold not be used in Markdown string parsing.
  Text.fromString(
    String text, {
    SourceLocation? start,
    SourceLocation? end,
  })  : _tabRemaining = null,
        _lineEndingToWhitespace = false,
        super(
            start ?? SourceLocation(0),
            end ??
                (start != null
                    ? SourceLocation(start.offset + text.length)
                    : SourceLocation(text.length)),
            text);

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        if (text != textContent) 'textContent': textContent,
        'start': start.toMap(),
        'end': end.toMap(),
      };

  @override
  String toString() => toMap().toPrettyString();
}

/// Inline content that has not been parsed into inline nodes (strong, links,
/// etc).
///
/// These placeholder nodes should only remain in place while the block nodes
/// of a document are still being parsed, in order to gather all reference link
/// definitions.
class UnparsedContent extends Text {
  UnparsedContent(
    super.text, {
    required super.start,
    required super.end,
  });

  /// Instantiates a [UnparsedContent] from [span].
  UnparsedContent.fromSpan(super.span) : super.fromSpan();
}

/// Visitor pattern for the AST.
///
/// Renderers or other AST transformers should implement this.
abstract class Visitor<T, E> {
  /// Called when an Element has been reached, before its children have been
  /// visited.
  ///
  /// Returns `false` to skip its children.
  bool visitElementBefore(E element);

  /// Called when an Element has been reached, after its children have been
  /// visited.
  ///
  /// Will not be called if [visitElementBefore] returns `false`.
  void visitElementAfter(E element);

  /// Called when a Text node has been reached.
  void visitText(T text);
}

abstract class NodeVisitor extends Visitor<Text, Element> {}
