// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../charcode.dart';
import '../extensions.dart';
import '../parsers/block_parser.dart';
import '../parsers/source_parser.dart';
import '../patterns.dart';
import '../syntax.dart';

/// Parses tables.
class TableSyntax extends BlockSyntax {
  @override
  bool canInterrupt(BlockParser parser) => false;

  @override
  RegExp get pattern => dummyPattern;

  const TableSyntax();

  @override
  bool canParse(BlockParser parser) {
    // Note: matches *next* line, not the current one. We're looking for the
    // bar separating the head row from the body rows.
    return parser.next?.hasMatch(tablePattern) ?? false;
  }

  /// Parses a table into its three parts:
  ///
  /// * a head row of head cells
  /// * a divider of hyphens and pipes (not rendered)
  /// * many body rows of body cells
  @override
  BlockElement? parse(BlockParser parser) {
    final markers = [parser.next!.content.trim()];

    final alignments = _parseDelimiterRow(parser.next!.content.text);
    final columnCount = alignments.length;
    final parsedRow = _parseRow(
      parser.current.content,
      alignments: alignments,
      expectedColumns: columnCount,
      inTableHead: true,
    );

    if (parsedRow == null) {
      return null;
    }

    markers.insertAll(0, parsedRow.markers);
    final head = BlockElement('tableHead', children: [parsedRow.row]);
    parser.advance();

    // Advance past the divider of hyphens.
    parser.advance();

    final rows = <BlockElement>[];
    while (!shouldEnd(parser)) {
      final parsedRow = _parseRow(
        parser.current.content,
        alignments: alignments,
        expectedColumns: columnCount,
        inTableHead: false,
      );
      markers.addAll(parsedRow!.markers);
      rows.add(parsedRow.row);
      parser.advance();
    }

    BlockElement? body;
    if (rows.isNotEmpty) {
      body = BlockElement('tableBody', children: rows);
    }
    return BlockElement(
      'table',
      children: [head, if (body != null) body],
      markers: markers,
    );
  }

  List<String?> _parseDelimiterRow(String text) {
    final columns = text.replaceAll(RegExp(r'^\s*\||\|\s*$'), '').split('|');

    return columns.map((column) {
      column = column.trim();
      final matchLeft = column.startsWith(':');
      final matchRight = column.endsWith(':');

      if (matchLeft && matchRight) return 'center';
      if (matchLeft) return 'left';
      if (matchRight) return 'right';
      return null;
    }).toList();
  }

  /// Parses a table row at the current line into a table row element, with
  /// parsed table cells.
  _RowElements? _parseRow(
    SourceSpan content, {
    required bool inTableHead,
    required int expectedColumns,
    required List<String?> alignments,
  }) {
    final markers = <SourceSpan>[];
    final cells = <List<InlineObject>>[];
    final spanParser = SourceParser([content.trimRight()]);

    /// Walks through the opening pipe and any whitespace that surrounds it.
    spanParser.moveThroughWhitespace();
    if (spanParser.charAt() == $pipe) {
      markers.add(spanParser.spanAt());
      spanParser.advance();
    }

    var cellStart = spanParser.position;
    final segments = <SourceSpan>[];
    while (!spanParser.isDone) {
      if (cells.length == expectedColumns) {
        if (inTableHead) {
          return null;
        }

        // https://github.github.com/gfm/#example-204
        // But save the excess in markers instead of ignoring.
        markers.add(spanParser.subspan(spanParser.position).single.trim());
        break;
      }

      final char = spanParser.charAt();
      final isLastChar = spanParser.nextChar() == null;

      // GitHub Flavored Markdown has a strange bit here; the pipe is to be
      // escaped before any other inline processing. One consequence, for
      // example, is that "| `\|` |" should be parsed as a cell with a code
      // element with text "|", rather than "\|". Most parsers are not
      // compliant with this corner, but this is what is specified, and what
      // GitHub does in practice.
      // See https://github.github.com/gfm/#example-200.
      if (char == $backslash && !isLastChar) {
        segments.addAll(spanParser.subspan(cellStart, spanParser.position));

        // Save "\" as a marker.
        markers.add(spanParser.spanAt());
        spanParser.advance();

        cellStart = spanParser.position;
        spanParser.advance();
        continue;
      }

      if (char == $pipe || isLastChar) {
        if (char == $pipe) {
          markers.add(spanParser.spanAt());
        }
        segments.addAll(spanParser.subspan(
          cellStart,
          (isLastChar && char != $pipe) ? null : spanParser.position,
        ));

        if (segments.isNotEmpty) {
          segments.first = segments.first.trimLeft();
          segments.last = segments.last.trimRight();
        }
        cells.add(
          segments
              .map<InlineObject>(UnparsedContent.fromSpan)
              .toList(),
        );
        segments.clear();
        if (!isLastChar) {
          spanParser.advance();
          cellStart = spanParser.position;
          continue;
        }
      }
      spanParser.advance();
    }

    if (inTableHead && cells.length != expectedColumns) {
      return null;
    }

    final rowChildren = <InlineElement>[];
    for (var i = 0; i < cells.length; i++) {
      String? textAlign;
      if (i < alignments.length && alignments[i] != null) {
        textAlign = '${alignments[i]}';
      }

      rowChildren.add(InlineElement(
        inTableHead ? 'tableHeadCell' : 'tableBodyCell',
        children: cells[i],
        attributes: textAlign == null ? {} : {'textAlign': textAlign},
      ));
    }

    if (!inTableHead) {
      while (rowChildren.length < expectedColumns) {
        // Insert synthetic empty cells.
        rowChildren.add(const InlineElement('tableBodyCell'));
      }
    }

    return _RowElements(
      BlockElement('tableRow', children: rowChildren),
      markers,
    );
  }
}

class _RowElements {
  final BlockElement row;
  final List<SourceSpan> markers;
  _RowElements(this.row, this.markers);
}
