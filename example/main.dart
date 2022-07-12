import 'package:dart_markdown/dart_markdown.dart';

void main() {
  print(markdownToHtml(
    'Hello **Markdown**!',
  ));
  //=> <p>Hello <strong>Markdown</strong>!</p>
}
