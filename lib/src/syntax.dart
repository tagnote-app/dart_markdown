// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import 'ast.dart';
import 'line.dart';
import 'parsers/block_parser.dart';
import 'parsers/inline_parser.dart';

abstract class Syntax {
  const Syntax();
}

abstract class BlockSyntax extends Syntax {
  const BlockSyntax();

  /// Gets the regex used to identify the beginning of this block, if any.
  RegExp get pattern;

  /// If can interrupt a block.
  bool canInterrupt(BlockParser parser) => true;

  bool canParse(BlockParser parser) => parser.current.hasMatch(pattern);

  Node? parse(BlockParser parser);

  /// Returns the block which interrupts current syntax parsing if there is one,
  /// otherwise returns `null`.
  ///
  /// Make sure to check if [parser] `isDone` is `false` first.
  BlockSyntax? interruptedBy(BlockParser parser) {
    for (final syntax in parser.blockSyntaxes) {
      if (syntax.canParse(parser) && syntax.canInterrupt(parser)) {
        return syntax;
      }
    }

    return null;
  }

  /// If should end the current syntax parseing.
  bool shouldEnd(BlockParser parser) =>
      parser.isDone || interruptedBy(parser) != null;
}

/// Represents one kind of Markdown tag that can be parsed.
abstract class InlineSyntax extends Syntax {
  final RegExp pattern;

  /// The first character of [pattern], to be used as an efficient first check
  /// that this syntax matches the current parser position.
  final int? _startCharacter;

  /// Create a new [InlineSyntax] which matches text on [pattern].
  ///
  /// If [startCharacter] is passed, it is used as a pre-matching check which
  /// is faster than matching against [pattern].
  /// the [pattern].
  const InlineSyntax(
    this.pattern, {
    int? startCharacter,
  }) : _startCharacter = startCharacter;

  /// Tries to match at the postion [start] if is offered, otherwise start
  /// matching from parser's current position.
  Match? tryMatch(InlineParser parser, [int? start]) {
    start ??= parser.position;

    // Before matching with the regular expression [pattern], which can be
    // expensive on some platforms, check if even the first character matches
    // this syntax.
    if (_startCharacter != null && parser.charAt(start) != _startCharacter) {
      return null;
    }

    return parser.matchFromStart(pattern, start);
  }

  /// Possibly creating a [Node] and advancing [parser].
  Node? parse(InlineParser parser, Match match);
}

class BlockSyntaxChildSource {
  final List<SourceSpan> markers;
  final List<Line> lines;

  /// If the lines is ending up with a lazy continuation line.
  final bool lazyEnding;

  BlockSyntaxChildSource({
    this.markers = const [],
    this.lines = const [],
    this.lazyEnding = false,
  });
}
