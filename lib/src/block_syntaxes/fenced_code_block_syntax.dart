// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../helpers/util.dart';
import '../line.dart';
import '../parsers/backslash_parser.dart';
import '../parsers/block_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

/// Parses preformatted code blocks between two ~~~ or ``` sequences.
///
/// See the CommonMark spec: https://spec.commonmark.org/0.30/#fenced-code-blocks
class FencedCodeBlockSyntax extends BlockSyntax {
  @override
  RegExp get pattern => codeFencePattern;

  const FencedCodeBlockSyntax();

  SourceSpan _removeIndentation(SourceSpan content, int length) {
    final text = content.text.replaceFirst(RegExp('^\\s{0,$length}'), '');
    return content.subspan(content.length - text.length);
  }

  BlockSyntaxChildSource parseChildLines(
    BlockParser parser,
    String endMarker,
    int indent,
  ) {
    final lines = <Line>[];
    final markders = [parser.current.content];

    parser.advance();

    while (!parser.isDone) {
      final match = parser.current.firstMatch(pattern);
      final parsedMatch = match == null ? null : _FenceMatch.fromMatch(match);

      // Closing code fences cannot have info strings:
      // https://spec.commonmark.org/0.30/#example-147
      if (parsedMatch == null ||
          !parsedMatch.marker.startsWith(endMarker) ||
          parsedMatch.info.isNotEmpty) {
        lines.add(Line(
          _removeIndentation(parser.current.content, indent),
          lineEnding: parser.current.lineEnding,
        ));
        parser.advance();
      } else {
        markders.add(parser.current.content);
        parser.advance();
        break;
      }
    }

    return BlockSyntaxChildSource(
      lines: lines,
      markers: markders,
    );
  }

  @override
  BlockElement parse(BlockParser parser) {
    final match = _FenceMatch.fromMatch(pattern.firstMatch(
      BackslashParser.parseString(parser.current.content.text),
    )!);
    final childSource = parseChildLines(parser, match.marker, match.indent);
    final codeLines = childSource.lines.toNodes(Text.fromSpan).nodes;

    final attributes = <String, String>{};

    if (match.info.isNotEmpty) {
      attributes.addAll({
        'infoString': decodeHtmlCharacters(match.info),
        'language': decodeHtmlCharacters(match.language),
      });
    }

    final markers = childSource.markers;

    return BlockElement(
      'fencedCodeBlock',
      children: codeLines,
      attributes: attributes,
      markers: childSource.markers,
      start: markers.first.start,
      end: markers.length > 1
          ? markers.last.end
          : (codeLines.isNotEmpty ? codeLines.last.end : markers.single.end),
    );
  }
}

class _FenceMatch {
  _FenceMatch.fromMatch(Match match)
      : indent = match[1]!.length,
        marker = match[4] == null ? match[2]! : match[4]!,
        _info = match[4] == null ? match[3]! : match[5]!;

  final int indent;
  final String marker;
  final String _info;

  // The info-string should be trimmed,
  // https://spec.commonmark.org/0.30/#info-string.
  String get info => _info.trim();

  // The first word of the info string is typically used to specify the language
  // of the code sample,
  // https://spec.commonmark.org/0.30/#example-143.
  String get language => info.split(' ').first;
}
