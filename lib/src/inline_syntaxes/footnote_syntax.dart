// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../charcode.dart';
import '../extensions.dart';
import '../parsers/inline_parser.dart';
import '../syntax.dart';

// See https://www.markdownguide.org/extended-syntax/#footnotes
class FootnoteSyntax extends InlineSyntax {
  static const _pattern = r'\[\^([^\s\]]+?)\]';

  FootnoteSyntax() : super(RegExp(_pattern), startCharacter: $lbracket);

  @override
  Node? parse(InlineParser parser, Match match) {
    final label = match[1]!;
    final number = parser.document.markFootnoteReference(label);
    if (number == null) {
      return null;
    }

    return Element(
      'footnote',
      markers: [parser.consumeBy(match.match.length).single],
      attributes: {'number': number, 'label': label},
    );
  }
}
