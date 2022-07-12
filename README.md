A portable Markdown library written in Dart. It can parse Markdown into HTML on
both the client and server.

This library is refactored from
[dart-lang/markdown(5.0)](https://pub.dev/packages/markdown/versions/5.0.0)

### Usage

```dart
import 'package:dart_markdown/dart_markdown.dart';

void main() {
  print(markdownToHtml('Hello *Markdown*'));
  //=> <p>Hello <em>Markdown</em></p>
}
```
