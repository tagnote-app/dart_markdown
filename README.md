_This library is refactored from
[dart-lang/markdown(5.0)](https://pub.dev/packages/markdown/versions/5.0.0)_

[![Build Status](https://github.com/chenzhiguang/dart_markdown/actions/workflows/test-package.yml/badge.svg)](https://github.com/chenzhiguang/dart_markdown/actions/workflows/test-package.yml)
[![Pub](https://img.shields.io/pub/v/dart_markdown.svg)](https://pub.dev/packages/dart_markdown)

## About

A portable Markdown library written in Dart. It can parse Markdown to AST and
render to HTML on both the client and server.

## Live demo

https://markdown.tagnote.app

## Highlights

- [100% conform to CommonMark](https://spec.commonmark.org/0.30/)
- [100% conform to GFM](https://github.github.com/gfm/)
- [Output AST with the location information of each text and marker](#syntax-tree)

## Syntax tree

_Input:_

```Markdown
Hello **Markdown**!
```

_Output:_

```json
[
  {
    "type": "paragraph",
    "start": { "line": 0, "column": 0, "offset": 0 },
    "end": { "line": 0, "column": 19, "offset": 19 },
    "children": [
      {
        "text": "Hello ",
        "start": { "line": 0, "column": 0, "offset": 0 },
        "end": { "line": 0, "column": 6, "offset": 6 }
      },
      {
        "type": "strongEmphasis",
        "start": { "line": 0, "column": 6, "offset": 6 },
        "end": { "line": 0, "column": 18, "offset": 18 },
        "markers": [
          {
            "start": { "line": 0, "column": 6, "offset": 6 },
            "end": { "line": 0, "column": 8, "offset": 8 },
            "text": "**"
          },
          {
            "start": { "line": 0, "column": 16, "offset": 16 },
            "end": { "line": 0, "column": 18, "offset": 18 },
            "text": "**"
          }
        ],
        "children": [
          {
            "text": "Markdown",
            "start": { "line": 0, "column": 8, "offset": 8 },
            "end": { "line": 0, "column": 16, "offset": 16 }
          }
        ]
      },
      {
        "text": "!",
        "start": { "line": 0, "column": 18, "offset": 18 },
        "end": { "line": 0, "column": 19, "offset": 19 }
      }
    ]
  }
]
```

## Usage

```dart
import 'package:dart_markdown/dart_markdown.dart';

void main() {
  final markdown = Markdown(
    // The options with default value `true`.
    enableAtxHeading: true,
    enableBlankLine: true,
    enableBlockquote: true,
    enableIndentedCodeBlock: true,
    enableFencedBlockquote: true,
    enableFencedCodeBlock: true,
    enableList: true,
    enableParagraph: true,
    enableSetextHeading: true,
    enableTable: true,
    enableHtmlBlock: true,
    enableLinkReferenceDefinition: true,
    enableThematicBreak: true,
    enableAutolinkExtension: true,
    enableAutolink: true,
    enableBackslashEscape: true,
    enableCodeSpan: true,
    enableEmoji: true,
    enableEmphasis: true,
    enableHardLineBreak: true,
    enableImage: true,
    enableLink: true,
    enableRawHtml: true,
    enableSoftLineBreak: true,
    enableStrikethrough: true,

    // The options with default value `false`.
    enableHeadingId: false,
    enableHighlight: false,
    enableFootnote: false,
    enableTaskList: false,
    enableSubscript: false,
    enableSuperscript: false,
    enableKbd: false,
    forceTightList: false,

    // Customised syntaxes.
    extensions: const <Syntax>[],
  );

  // AST nodes.
  final nodes = markdown.parse('Hello **Markdown**!');

  final html = nodes.toHtml(
    enableTagfilter: false,
    encodeHtml: true,
  );

  print(html);
  //=> <p>Hello <strong>Markdown</strong>!</p>
}
```

## Custom syntax extension example

```dart
markdownToHtml(
  'a #hashtag',
  extensions: [
    ExampleSyntax(),
  ],
);

class ExampleSyntax extends InlineSyntax {
  ExampleSyntax() : super(RegExp(r'#[^#]+?(?=\s+|$)'));

  @override
  MdInlineObject? parse(MdInlineParser parser, Match match) {
    final markers = [parser.consume()];
    final content = parser.consumeBy(match[0]!.length - 1);

    return MdInlineElement(
      'hashtag',
      markers: markers,
      children: content.map((e) => MdText.fromSpan(e)).toList(),
    );
  }
}
```
