_This library is refactored from
[dart-lang/markdown(5.0)](https://pub.dev/packages/markdown/versions/5.0.0)_

### About

A portable Markdown library written in Dart. It can parse Markdown into HTML on
both the client and server.

### Live demo

https://chenzhiguang.github.io/dart_markdown_demo/

### Usage

```dart
import 'package:dart_markdown/dart_markdown.dart';

void main() {
  print(markdownToHtml(
    'Hello **Markdown**!',

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
    encodeHtml: true,

    // The options with default value `false`.
    enableHeadingId: false,
    enableHighlight: false,
    enableFootnote: false,
    enableTaskList: false,
    enableSubscript: false,
    enableSuperscript: false,
    enableKbd: false,
    enableTagfilter: false,

    // Customised syntaxes.
    extensions: const <Syntax>[],
  ));
  //=> <p>Hello <strong>Markdown</strong>!</p>
}
```
