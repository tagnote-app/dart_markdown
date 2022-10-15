// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../extensions.dart';
import 'html_ast.dart';

class HtmlTransformer implements NodeVisitor {
  final bool encodeHtml;

  final _tree = <_TreeElement>[];
  final _footnoteReferences = <String, HtmlNode>{};

  String? _lastVisitElement;

  HtmlTransformer({
    this.encodeHtml = false,
  });

  List<HtmlNode> transform(List<Node> nodes) {
    _tree
      ..clear()
      ..add(_TreeElement());

    for (final node in nodes) {
      assert(_tree.length == 1);
      node.accept(this);
    }

    if (_footnoteReferences.isNotEmpty) {
      _tree.single.children.add(_attachFootnotes());
    }

    return _tree.single.children;
  }

  HtmlElement _attachFootnotes() {
    final entries = _footnoteReferences.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    final items = entries.map((e) => e.value).toList();
    return HtmlElement(
      'ol',
      items,
      attributes: {'class': 'footnotes'},
    );
  }

  @override
  bool visitElementBefore(Element element) {
    if (element.type == 'linkReferenceDefinition') {
      return false;
    }

    if (element.type == 'htmlBlock') {
      var text =
          element.children.map((e) => (e as Text).text).join().trimRight();

      // Hackish. In order to strick for example:
      // https://spec.commonmark.org/0.30/#example-167
      // Maybe we should agree to add a special HTML tag `htmlBlock`, so we can
      // achive the same result in HtmlRenderer.
      text = (_lastVisitElement != null ? '\n' : '') + text;
      if (_lastVisitElement == 'listItem') {
        text += '\n';
      }
      _tree.last.children.add(HtmlText(text));
      return false;
    } else if (element.type == 'inlineHtml') {
      _tree.last.children.add(
        HtmlText(element.children.map((e) => (e as Text).text).join()),
      );
      return false;
    } else if (element.type == 'emoji') {
      _tree.last.children.add(HtmlText(element.attributes['emoji']!));
      return false;
    }

    _lastVisitElement = element.type;
    _tree.add(_TreeElement(element));
    return true;
  }

  @override
  void visitElementAfter(Element element) {
    final current = _tree.removeLast();
    final type = element.type;
    final attributes = element.attributes;

    HtmlElement node;

    if (_isCodeBlock(type)) {
      final code = HtmlElement('code', current.children);

      if (attributes['language'] != null) {
        var language = attributes['language']!;
        if (encodeHtml) {
          language = language.toHtmlText();
        }
        code.attributes['class'] = 'language-$language';
      }

      node = HtmlElement('pre', [code]);
    } else {
      var tag = _htmlTagMap[type] ?? type;

      if (_isHealine(type)) {
        tag = 'h${attributes['level']}';
      }

      if (_isSelfClosing(element)) {
        node = HtmlElement.empty(tag);

        if (type == 'image') {
          node.attributes.addAll({
            'src': attributes['destination']!,
            if (attributes['description'] != null)
              'alt': attributes['description']!,
            if (attributes['title'] != null) 'title': attributes['title']!,
          });
        }
      } else {
        node = HtmlElement(tag, current.children);

        if (_isHealine(type)) {
          node.generatedId = attributes['generatedId'];
        } else if (type == 'orderedList' && attributes['start'] != null) {
          node.attributes['start'] = attributes['start']!;
        } else if (type == 'listItem' && attributes['taskListItem'] != null) {
          final checkboxInput = HtmlElement.empty('input');
          node.attributes['class'] = 'task-list-item';
          checkboxInput.attributes.addAll({
            'type': 'checkbox',
            if (attributes['taskListItem'] == 'checked') 'checked': '',
          });

          // Add a whitespace between input and text.
          // This whitespace should not be added in Markdown AST tree, because
          // some output targets such as Flutter might not want this whitespace.
          node.children?.insertAll(0, [checkboxInput, HtmlText(' ')]);
        } else if (type == 'tableHeadCell' || type == 'tableBodyCell') {
          if (attributes['textAlign'] != null) {
            node.attributes['align'] = attributes['textAlign']!;
          }
        } else if (type == 'link') {
          node.attributes.addAll({
            if (attributes['destination'] != null)
              'href': attributes['destination']!,
            if (attributes['title'] != null) 'title': attributes['title']!,
          });

          if (attributes['text'] != null) {
            node.children!
              ..clear()
              ..add(HtmlText(attributes['text']!));
          }
        } else if (type == 'footnote') {
          final label = attributes['label'];
          final link = HtmlElement('a', [
            HtmlText(attributes['number']!)
          ], attributes: {
            'href': '#fn:$label',
          });
          node.attributes.addAll({
            'id': 'fnref:$label',
            'class': 'footnote',
          });
          node.children!.add(link);
        } else if (type == 'footnoteReference') {
          final number = element.attributes['number'];
          final label = attributes['label'];
          // ignore the ones are not connected to footnote.
          if (number == null) {
            return;
          }
          final link = HtmlElement('a', [
            HtmlText('↩')
          ], attributes: {
            'class': 'footnote-reverse',
            'href': '#fnref:$label',
          });
          node.attributes['id'] = 'fn:$label';
          node.children!.add(link);
          _footnoteReferences[number] = node;
          // Do not write to tree.
          return;
        }
      }
    }

    _lastVisitElement = type;
    _tree.last.children.add(node);
  }

  @override
  void visitText(Text text) {
    final parent = _tree.last;
    final parentType = parent.element?.type;
    final decodeHtmlCharacter =
        parentType != 'inlineCode' && !_isCodeBlock(parentType);

    var content = !encodeHtml
        ? text.textContent
        : text.htmlText(decodeHtmlCharacter: decodeHtmlCharacter);

    if (parentType == 'kbd') {
      content = content.replaceAll('\n', '<br />');
    }

    if (text is! UnparsedContent) {
      parent.children.add(HtmlText(content));
    }

    _lastVisitElement = null;
  }

  bool _isCodeBlock(String? type) =>
      type == 'indentedCodeBlock' || type == 'fencedCodeBlock';

  bool _isHealine(String? type) =>
      type == 'setextHeading' || type == 'atxHeading';

  bool _isSelfClosing(Element element) =>
      [
        'image',
        'thematicBreak',
        'hardLineBreak',
      ].contains(element.type) &&
      element.children.isEmpty;
}

class _TreeElement {
  final Element? element;
  final children = <HtmlNode>[];

  _TreeElement([this.element]);
}

const _htmlTagMap = {
  'paragraph': 'p',
  'orderedList': 'ol',
  'bulletList': 'ul',
  'listItem': 'li',
  'thematicBreak': 'hr',
  'tableRow': 'tr',
  'tableHead': 'thead',
  'tableBody': 'tbody',
  'tableHeadCell': 'th',
  'tableBodyCell': 'td',
  'inlineCode': 'code',
  'hardLineBreak': 'br',
  'emphasis': 'em',
  'strongEmphasis': 'strong',
  'strikethrough': 'del',
  'link': 'a',
  'image': 'img',
  'subscript': 'sub',
  'superscript': 'sup',
  'highlight': 'mark',
  'footnote': 'sup',
  'footnoteReference': 'li',
};
