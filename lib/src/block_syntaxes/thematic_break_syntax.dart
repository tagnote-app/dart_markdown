// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../helpers/extensions.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

/// Parses horizontal rules like `---`, `_ _ _`, `*  *  *`, etc.
class ThematicBreakSyntax extends BlockSyntax {
  @override
  RegExp get pattern => hrPattern;

  const ThematicBreakSyntax();

  @override
  BlockElement parse(BlockParser parser) {
    final marker = parser.current.content;

    parser.advance();

    final finalMarker = marker.trim();
    return BlockElement(
      'thematicBreak',
      markers: [finalMarker],
      start: finalMarker.start,
      end: finalMarker.end,
    );
  }
}
