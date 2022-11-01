import '../dart_markdown.dart';

const text = '''
| Foo |
| -- |
|
''';
void main() {
  print(Markdown().parse(text).toHtml());
}
