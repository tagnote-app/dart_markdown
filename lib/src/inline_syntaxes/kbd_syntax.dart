// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../charcode.dart';
import '../extensions.dart';
import '../parsers/inline_parser.dart';
import '../syntax.dart';

// This syntax works even though RawHtmlSyntax and HtmlBlockSyntax are disabled.
class KbdSyntax extends InlineSyntax {
  KbdSyntax()
      : super(
          RegExp(r'<kbd>.+?<\/kbd>',
              caseSensitive: false, multiLine: true, dotAll: true),
          startCharacter: $lt,
        );

  @override
  Node? parse(InlineParser parser, Match match) {
    final matchedLength = match.match.length;
    final markers = [
      parser.consumeBy(5).single,
    ];

    final contentSpans = parser.consumeBy(matchedLength - 11);
    contentSpans[0] = contentSpans[0].trimLeft();
    final lastSpan = contentSpans.removeLast().trimRight();
    contentSpans.add(lastSpan);

    markers.add(parser.consumeBy(6).single);

    return Element(
      'kbd',
      markers: markers,
      children: contentSpans.map<Node>((e) => Text.fromSpan(e)).toList(),
    );
  }
}
