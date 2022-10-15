import 'package:dart_markdown/dart_markdown.dart';

void main() {
  final markdown = Markdown();

  // AST nodes.
  final nodes = markdown.parse('Hello **Markdown**!');

  // Convert to an HTML string.
  final html = nodes.toHtml();

  print(html);
  //=> <p>Hello <strong>Markdown</strong>!</p>
}
