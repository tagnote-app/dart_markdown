// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../charcode.dart';
import 'delimiter_syntax.dart';

class CaretSyntax extends DelimiterSyntax {
  CaretSyntax({
    bool enableSuperscript = false,
  }) : super(
          r'\^+',
          requiresDelimiterRun: true,
          allowIntraWord: true,
          startCharacter: $caret,
          tags: [
            if (enableSuperscript) DelimiterTag('superscript', 1),
          ],
        );
}
