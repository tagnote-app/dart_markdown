// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../charcode.dart';
import 'delimiter_syntax.dart';

class TildeSyntax extends DelimiterSyntax {
  TildeSyntax({
    bool enableStrikethrough = false,
    bool enableSubscript = false,
  }) : super(
          '~+',
          requiresDelimiterRun: true,
          allowIntraWord: true,
          startCharacter: $tilde,
          tags: [
            if (enableSubscript) DelimiterTag('subscript', 1),
            if (enableStrikethrough) DelimiterTag('strikethrough', 2),
          ],
        );
}
