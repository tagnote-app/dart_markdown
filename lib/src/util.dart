// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';
import 'assets/case_folding.dart';
import 'assets/html_entities.dart';
import 'ast.dart';
import 'line.dart';

/// One or more whitespace, for compressing.
final _oneOrMoreWhitespacePattern = RegExp('[ \n\r\t]+');

/// "Normalizes" a link label, according to the [CommonMark spec].
///
/// [CommonMark spec] https://spec.commonmark.org/0.30/#link-label
String normalizeLinkLabel(String label) {
  final text = label.trim().replaceAll(_oneOrMoreWhitespacePattern, ' ');
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    buffer.write(caseFoldingMap[text[i]] ?? text[i]);
  }
  return buffer.toString();
}

/// Generates a valid HTML anchor from the inner text of [element].
// TODO(Zhiguang): Support unicode text.
String generateAnchorHash(List<Node> nodes) => nodes
    .map((e) => e.textContent
        .toLowerCase()
        .trim()
        .replaceAll(RegExp('[^a-z0-9 _-]'), '')
        .replaceAll(RegExp(r'\s'), '-'))
    .join();

/// Converts string to `List<Line>` lines.
List<Line> stringToLines(String text) {
  final stringLines = text.split('\n');
  final lines = <Line>[];

  var offset = 0;
  for (var i = 0; i < stringLines.length; i++) {
    // Ignore the last blank line. This blank line is produced by the line
    // ending of the previous line, and followd by the end of file.
    if (stringLines.length == i + 1 && stringLines[i].isEmpty) {
      break;
    }

    var text = stringLines[i];
    final hasCarriageReturn = text.endsWith('\r');
    if (hasCarriageReturn) {
      text = text.substring(0, text.length - 1);
    }

    final start = SourceLocation(offset, column: 0, line: i);
    offset += text.length;
    final end = SourceLocation(offset, column: text.length, line: i);
    final content = SourceSpan(start, end, text);

    SourceSpan? lineEnding;
    if (i < stringLines.length - 1) {
      final lineEndingString = !hasCarriageReturn ? '\n' : '\r\n';
      final endOffset = offset + lineEndingString.length;

      lineEnding = SourceSpan(
        SourceLocation(offset, column: end.column, line: i),
        SourceLocation(endOffset, column: 0, line: i + 1),
        lineEndingString,
      );
      offset = endOffset;
    }

    lines.add(Line(content, lineEnding: lineEnding));
  }

  return lines;
}

///  Decodes HTML entity and numeric character references, for example decode
/// `&#35` to `#`.
String decodeHtmlCharacters(String input) {
  final pattern = RegExp(
    '&(?:([a-z0-9]+)|#([0-9]{1,7})|#x([a-f0-9]{1,6}));',
    caseSensitive: false,
  );

  return input.replaceAllMapped(pattern, (match) {
    final text = match[0]!;

    // Entity references, see
    // https://spec.commonmark.org/0.30/#entity-references.
    if (match[1] != null) {
      return htmlEntitiesMap[text] ?? text;
    }

    // Decimal numeric character references, see
    // https://spec.commonmark.org/0.30/#decimal-numeric-character-references.
    if (match[2] != null) {
      final decimalValue = int.parse(match[2]!);
      int hexValue;
      if (decimalValue < 1114112 && decimalValue > 1) {
        hexValue = int.parse(decimalValue.toRadixString(16), radix: 16);
      } else {
        hexValue = 0xFFFd;
      }
      return String.fromCharCode(hexValue);
    }

    // Hexadecimal numeric character references, see
    // https://spec.commonmark.org/0.30/#hexadecimal-numeric-character-references.
    if (match[3] != null) {
      var hexValue = int.parse(match[3]!, radix: 16);
      if (hexValue > 0x10ffff || hexValue == 0) {
        hexValue = 0xFFFd;
      }
      return String.fromCharCode(hexValue);
    }

    return text;
  });
}
