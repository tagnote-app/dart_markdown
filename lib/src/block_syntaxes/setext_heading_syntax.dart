// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../extensions.dart';
import '../line.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';
import '../util.dart';
import 'paragraph_syntax.dart';

/// Parses setext-style headers.
class SetextHeadingSyntax extends BlockSyntax {
  @override
  RegExp get pattern => setextPattern;

  const SetextHeadingSyntax({
    bool enableHeadingId = false,
  }) : _headingIdEnabled = enableHeadingId;

  final bool _headingIdEnabled;

  @override
  bool canParse(BlockParser parser) {
    final lastSyntax = parser.currentSyntax;
    if (parser.setextHeadingDisabled || lastSyntax is! ParagraphSyntax) {
      return false;
    }
    return parser.current.hasMatch(pattern);
  }

  @override
  Node? parse(BlockParser parser) {
    final lines = parser.linesToConsume;
    if (lines.length < 2) {
      return null;
    }

    // Remove the last line which is a marker.
    lines.removeLast();

    final marker = parser.current.content.trim();
    final level = (marker.text[0] == '=') ? '1' : '2';
    final content = lines.toNodes(
      ((e) => UnparsedContent.fromSpan(e)),
      trimLeading: true,
      trimTrailing: true,
      popLineEnding: true,
    );

    parser.advance();

    return Element(
      'headline',
      children: content.nodes,
      attributes: {
        'level': level,
        if (_headingIdEnabled) 'generatedId': generateAnchorHash(content.nodes),
      },
      markers: [marker],
    );
  }
}
