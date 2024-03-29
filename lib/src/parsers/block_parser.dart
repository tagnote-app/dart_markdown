// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../block_syntaxes/blank_line_syntax.dart';
import '../line.dart';
import '../markdown.dart';
import '../syntax.dart';

/// Maintains the internal state needed to parse a series of lines into blocks
/// of Markdown suitable for further inline parsing.
class BlockParser {
  final List<Line> _lines;

  /// The Markdown document this parser is parsing.
  final Markdown document;

  /// The enabled block syntaxes.
  ///
  /// To turn a series of lines into blocks, each of these will be tried in
  /// turn. Order matters here.
  Iterable<BlockSyntax> get blockSyntaxes => document.blockSyntaxes;

  /// Index of the current line.
  int _pos = 0;

  /// Starting line of the last unconsumed content.
  int _start = 0;

  /// The lines from [_start] to [_pos] (inclusive)
  List<Line> get linesToConsume => _lines.getRange(_start, _pos + 1).toList();

  int get position => _pos;

  /// Whether the parser has encountered a blank line between two block-level
  /// elements.
  bool encounteredBlankLine = false;

  BlockParser(List<Line> lines, this.document) : _lines = lines;

  /// Gets the current line.
  Line get current => _lines[_pos];

  /// Gets the line after the current one or `null` if there is none.
  Line? get next {
    // Don't read past the end.
    if (_pos >= _lines.length - 1) return null;
    return _lines[_pos + 1];
  }

  /// Gets the line that is [linesAhead] lines ahead of the current one, or
  /// `null` if there is none.
  ///
  /// `peek(0)` is equivalent to [current].
  ///
  /// `peek(1)` is equivalent to [next].
  Line? peek(int linesAhead) {
    if (linesAhead < 0) {
      throw ArgumentError('Invalid linesAhead: $linesAhead; must be >= 0.');
    }
    // Don't read past the end.
    if (_pos >= _lines.length - linesAhead) return null;
    return _lines[_pos + linesAhead];
  }

  /// The [BlockSyntax] which is running now.
  BlockSyntax? get currentSyntax => _currentSyntax;
  BlockSyntax? _currentSyntax;

  /// The parent [BlockSyntax] when it is running in a nested syntax.
  BlockSyntax? get parentSyntax => _parentSyntax;
  BlockSyntax? _parentSyntax;

  /// If the [SetextHeadingSyntax] is disabled temporarily
  bool get setextHeadingDisabled => _setextHeadingDisabled;
  bool _setextHeadingDisabled = false;

  bool get isDone => _pos >= _lines.length;

  void advance() {
    _pos++;
  }

  void setLine(int line) => _pos = line;

  List<Node> parseLines({
    bool disabledSetextHeading = false,
    BlockSyntax? fromSyntax,
  }) {
    _setextHeadingDisabled = disabledSetextHeading;
    _parentSyntax = fromSyntax;

    int? dirtyPosition;
    // If the `_pos` did not change before and after parse(), never try to match
    // the same `_pos` again.
    final neverMatch = <BlockSyntax>[];

    final blocks = <Node>[];
    while (!isDone) {
      for (final syntax in blockSyntaxes) {
        if (dirtyPosition == _pos && neverMatch.contains(syntax)) {
          continue;
        }
        if (syntax.canParse(this)) {
          _currentSyntax = syntax;
          final positionBefore = _pos;
          final block = syntax.parse(this);
          if (_pos > positionBefore) {
            neverMatch.clear();
          } else {
            dirtyPosition = _pos;
            neverMatch.add(syntax);
          }

          if (block != null || syntax is BlankLineSyntax) {
            _start = _pos;
          }
          if (block != null) {
            blocks.add(block);
          }
          break;
        }
      }
    }

    return blocks;
  }
}
