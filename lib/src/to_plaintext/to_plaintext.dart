// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';

extension NodesToPlaintextExtensions on List<Node> {
  /// Outputs a [Node] list as plain text.
  String toPlaintext({
    String? replaceLineEnding,
    int? maxLength,
  }) {
    return _PlaintextRenderer(
      maxLength: maxLength,
      replaceLineEnding: replaceLineEnding,
    ).render(this);
  }
}

class _PlaintextRenderer implements NodeVisitor {
  _PlaintextRenderer({
    int? maxLength,
    String? replaceLineEnding,

    // TODO(Zhiguang): Enable this option.
    bool escapeHtml = false,
  })  : _escapeHtml = escapeHtml,
        _maxLength = maxLength,
        _replaceLineEnding = replaceLineEnding;

  final bool _escapeHtml;
  final int? _maxLength;
  final String? _replaceLineEnding;
  final buffer = StringBuffer();

  var _stopped = false;

  String render(List<Node> nodes) {
    for (final node in nodes) {
      if (_stopped) {
        break;
      }
      node.accept(this);
    }

    final text = buffer.toString();
    if (_maxLength == null || _maxLength! >= text.length) {
      return text;
    }

    return text.substring(0, _maxLength);
  }

  @override
  void visitElementAfter(Element<Node> element) {}

  @override
  bool visitElementBefore(Element<Node> element) {
    if (_stopped) {
      return false;
    }
    if (buffer.isNotEmpty && element.isBlock) {
      _writeln();
    }
    return true;
  }

  @override
  void visitText(Text text) {
    if (_maxLength != null && buffer.length >= _maxLength!) {
      _stopped = true;
      return;
    }

    var content = text.text;

    if (_escapeHtml) {
      content = text.htmlText();
    }
    if (_replaceLineEnding != null) {
      content = content.replaceAll('\n', _replaceLineEnding!);
    }

    buffer.write(content);
  }

  void _writeln() {
    if (_replaceLineEnding == null) {
      buffer.writeln();
    } else {
      buffer.write(_replaceLineEnding);
    }
  }
}
