// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../extensions.dart';
import '../parsers/inline_parser.dart';
import '../syntax.dart';

/// Represents a hard line break.
class HardLineBreakSyntax extends InlineSyntax {
  HardLineBreakSyntax() : super(RegExp(r'(?:\\|  +)\n'));

  /// Create a void <br> element.
  @override
  InlineElement parse(InlineParser parser, Match match) {
    final marker = parser.consumeBy(match.match.length - 1).first;
    parser.advance();

    return InlineElement(
      'hardLineBreak',
      markers: [marker],
    );
  }
}
