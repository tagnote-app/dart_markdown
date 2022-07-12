// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../charcode.dart';
import '../document.dart';
import '../inline_syntaxes/delimiter_syntax.dart';
import '../inline_syntaxes/link_syntax.dart';
import '../syntax.dart';
import 'delimiter_processor.dart';
import 'source_parser.dart';

/// Maintains the internal state needed to parse inline span elements in
/// Markdown.
class InlineParser extends SourceParser {
  /// The Markdown document this parser is parsing.
  final Document document;

  final List<InlineSyntax> syntaxes = <InlineSyntax>[];

  /// Starting position of the last unconsumed text.
  int _textStart = 0;

  late final DelimiterProcessor _delimiterProcessor;

  /// The tree of parsed Markdown nodes.
  final _tree = <Node>[];

  InlineParser(List<UnparsedContent> source, this.document) : super(source) {
    // User specified syntaxes are the first syntaxes to be evaluated.
    syntaxes.addAll(document.inlineSyntaxes);
  }

  List<Node> parse() {
    _delimiterProcessor = DelimiterProcessor(this, _tree);
    final neverMatch = <InlineSyntax>[];
    final hasLinkSyntax = (syntaxes.any(((e) => e is LinkSyntax)));
    int? dirtyPosition;

    while (!isDone) {
      // A right bracket (']') is special. Hitting this character triggers the
      // "look for link or image" procedure.
      // See https://spec.commonmark.org/0.29/#an-algorithm-for-parsing-nested-emphasis-and-links.
      if (hasLinkSyntax && charAt() == $rbracket) {
        writeText();
        if (_delimiterProcessor.buildLinkOrImage()) {
          _textStart = position;
        }
        continue;
      }

      // See if the current text matches any defined Markdown syntax.
      if (syntaxes.any((syntax) {
        if (dirtyPosition == position && neverMatch.contains(syntax)) {
          return false;
        }

        final match = syntax.tryMatch(this);
        if (match == null) {
          return false;
        }

        writeText();
        final positionBefore = position;
        final node = syntax.parse(this, match);

        // If the position was not changed after parsing, never match this
        // syntax again at the same position.
        //
        // It makes it possible that even though `tryMatch()` matched, the
        // `parse()` still have the chance to regret the match and leave the
        // matched content for other syntaxes.
        //
        // `EmojiSyntax` is an example of this feature.
        if (position > positionBefore) {
          neverMatch.clear();
        } else {
          dirtyPosition = position;
          neverMatch.add(syntax);
        }

        if (node != null) {
          _tree.add(node);
          _textStart = position;
        }

        return true;
      })) continue;

      advance();
    }

    // Write any trailing text content to a Text node.
    writeText();
    _delimiterProcessor.processDelimiterRun(-1);
    _combineAdjacentText(_tree);
    return _tree;
  }

  /// Combine all the adjacent [Text] nodes.
  void _combineAdjacentText(List<Node> nodes) {
    if (nodes.isEmpty) {
      return;
    }

    Text? text;
    var startAt = 0;
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];

      if (text != null && node is! Text) {
        nodes.replaceRange(startAt, i, [text]);
        i -= i - startAt;
        text = null;
      }

      if (node is Element) {
        _combineAdjacentText(node.children);
        continue;
      }

      if (node is Text) {
        if (text == null) {
          startAt = i;
          text = node;
        } else if (text.end.offset != node.start.offset) {
          nodes.replaceRange(startAt, i, [text]);
          i -= i - startAt;
          text = null;
        } else {
          text = text.concat(node);
        }
      }
    }
    if (text != null) {
      nodes.replaceRange(startAt, nodes.length, List<Text>.from([text]));
    }
  }

  void writeText() {
    if (position == _textStart) {
      return;
    }
    _tree.addAll(subspan(_textStart, position).map(
      (span) => Text.fromSpan(span),
    ));
    _textStart = position;
  }

  /// Skip a whitespace at current position.
  void skipWhitespace() {
    if (charAt() != $space || _textStart != position) {
      return;
    }
    advance();
    _textStart = position;
  }

  /// Push [delimiter] onto the stack of [Delimiter]s.
  void pushDelimiter(Delimiter delimiter) =>
      _delimiterProcessor.pushDelimiter(delimiter);
}
