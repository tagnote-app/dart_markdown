// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

// A line containing no characters, or a line containing only spaces (`U+0020`)
// or tabs (`U+0009`), is called a blank line.
// See https://spec.commonmark.org/0.30/#blank-line.
class BlankLineSyntax extends BlockSyntax {
  @override
  RegExp get pattern => emptyPattern;

  const BlankLineSyntax();

  @override
  BlockElement? parse(BlockParser parser) {
    parser
      ..encounteredBlankLine = true
      ..advance();

    while (!parser.isDone && parser.current.hasMatch(pattern)) {
      parser.advance();
    }

    return null;
  }
}
