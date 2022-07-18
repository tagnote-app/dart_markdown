// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../charcode.dart';
import '../parsers/inline_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

// Notice: Internal syntax, do not export it.

/// Escape ASCII punctuation preceded by a backslash.
///
/// Backslashes before other characters are treated as literal backslashes.
// See https://spec.commonmark.org/0.30/#backslash-escapes.
class BackslashEscapeSyntax extends InlineSyntax {
  static final _pattern = RegExp(
    r'\\'
    '[$asciiPunctuationEscaped]',
  );

  BackslashEscapeSyntax() : super(_pattern, startCharacter: $backslash);

  @override
  InlineElement parse(InlineParser parser, Match match) {
    final markers = [parser.consume()];
    final text = Text.fromSpan(parser.consume());

    return InlineElement(
      '_backslashEscape',
      children: [text],
      markers: markers,
    );
  }
}
