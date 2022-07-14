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
  // The pattern needs to start with an optional (!), otherwise the footnote has
  // a (!) before ([) will be caputured by `ImageSyntax`.
  static const _pattern = r'!?\[\^([^\s\]]+?)\]';

  FootnoteSyntax() : super(RegExp(_pattern));

  @override
  Node? parse(InlineParser parser, Match match) {
    final label = match[1]!;
    final number = parser.document.markFootnoteReference(label);
    if (number == null) {
      return null;
    }

    var markerLength = match.match.length;
    // Write (!) back.
    if (parser.charAt() == $exclamation) {
      parser
        ..advance()
        ..writeText();
      markerLength -= 1;
    }

    return Element(
      'footnote',
      markers: [parser.consumeBy(markerLength).single],
      attributes: {'number': number, 'label': label},
    );
  }
}
