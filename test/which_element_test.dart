import 'package:dart_markdown/dart_markdown.dart';
import 'package:test/test.dart';

void main() {
  group('only paragraph', () {
    const text = 'Bar';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['paragraph'],
        text: text,
        marker: null,
      ),
      1: const _Matcher(
        path: ['paragraph'],
        text: text,
        marker: null,
      ),
      2: const _Matcher(
        path: ['paragraph'],
        text: text,
        marker: null,
      ),
      3: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });

  group('paragraph with inline elements', () {
    const text = 'B**a**r';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['paragraph'],
        text: 'B',
        marker: null,
      ),
      1: const _Matcher(
        path: ['paragraph', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      2: const _Matcher(
        path: ['paragraph', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      3: const _Matcher(
        path: ['paragraph', 'strongEmphasis'],
        text: 'a',
        marker: null,
      ),
      4: const _Matcher(
        path: ['paragraph', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      5: const _Matcher(
        path: ['paragraph', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      6: const _Matcher(
        path: ['paragraph'],
        text: 'r',
        marker: null,
      ),
      7: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;
        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });

  group('paragraph with nested inline elements', () {
    const text = 'B***a***r';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['paragraph'],
        text: 'B',
        marker: null,
      ),
      1: const _Matcher(
        path: ['paragraph', 'emphasis'],
        text: null,
        marker: '*',
      ),
      2: const _Matcher(
        path: ['paragraph', 'emphasis', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      3: const _Matcher(
        path: ['paragraph', 'emphasis', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      4: const _Matcher(
        path: ['paragraph', 'emphasis', 'strongEmphasis'],
        text: 'a',
        marker: null,
      ),
      5: const _Matcher(
        path: ['paragraph', 'emphasis', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      6: const _Matcher(
        path: ['paragraph', 'emphasis', 'strongEmphasis'],
        text: null,
        marker: '**',
      ),
      7: const _Matcher(
        path: ['paragraph', 'emphasis'],
        text: null,
        marker: '*',
      ),
      8: const _Matcher(
        path: ['paragraph'],
        text: 'r',
        marker: null,
      ),
      9: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });

  group('blockquote', () {
    const text = '> B*ar*';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: '>',
      ),
      1: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: null,
      ),
      2: const _Matcher(
        path: ['blockquote', 'paragraph'],
        text: 'B',
        marker: null,
      ),
      3: const _Matcher(
        path: ['blockquote', 'paragraph', 'emphasis'],
        text: null,
        marker: '*',
      ),
      4: const _Matcher(
        path: ['blockquote', 'paragraph', 'emphasis'],
        text: 'ar',
        marker: null,
      ),
      5: const _Matcher(
        path: ['blockquote', 'paragraph', 'emphasis'],
        text: 'ar',
        marker: null,
      ),
      6: const _Matcher(
        path: ['blockquote', 'paragraph', 'emphasis'],
        text: null,
        marker: '*',
      ),
      7: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });
  group('blockquote with only a marker', () {
    const text = '>';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: '>',
      ),
      1: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });
  group('empty blockquote with only spaces', () {
    const text = '>  \n ';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: '>',
      ),
      1: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: null,
      ),
      2: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: null,
      ),
      3: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
      4: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
      5: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });

  group('nested block elements', () {
    const text = '> 1. f \n ';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: '>',
      ),
      1: const _Matcher(
        path: ['blockquote'],
        text: null,
        marker: null,
      ),
      2: const _Matcher(
        path: ['blockquote', 'orderedList', 'listItem'],
        text: null,
        marker: '1.',
      ),
      3: const _Matcher(
        path: ['blockquote', 'orderedList', 'listItem'],
        text: null,
        marker: '1.',
      ),
      4: const _Matcher(
        path: ['blockquote', 'orderedList', 'listItem'],
        text: null,
        marker: null,
      ),
      5: const _Matcher(
        path: ['blockquote', 'orderedList', 'listItem'],
        text: 'f',
        marker: null,
      ),
      6: const _Matcher(
        path: ['blockquote', 'orderedList', 'listItem'],
        text: null,
        marker: null,
      ),
      7: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
      8: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
      9: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });

  group('paragraph with hard line break', () {
    const text = 'a  \nb';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['paragraph'],
        text: 'a',
        marker: null,
      ),
      1: const _Matcher(
        path: ['paragraph', 'hardLineBreak'],
        text: null,
        marker: '  ',
      ),
      2: const _Matcher(
        path: ['paragraph', 'hardLineBreak'],
        text: null,
        marker: '  ',
      ),
      3: const _Matcher(
        path: ['paragraph'],
        text: null,
        marker: null,
      ),
      4: const _Matcher(
        path: ['paragraph'],
        text: 'b',
        marker: null,
      ),
      5: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });

  group('list with hard line break', () {
    // TODO(Zhiguang):
    // https://github.com/tagnote-app/dart_markdown/issues/75
    const text = '+ a \\\nb';
    final nodes = toAst(text);
    final matchers = {
      0: const _Matcher(
        path: ['bulletList', 'listItem'],
        text: null,
        marker: '+',
      ),
      1: const _Matcher(
        path: ['bulletList', 'listItem'],
        text: null,
        marker: null,
      ),
      2: const _Matcher(
        path: ['bulletList', 'listItem'],
        text: 'a ',
        marker: null,
      ),
      3: const _Matcher(
        path: ['bulletList', 'listItem'],
        text: 'a ',
        marker: null,
      ),
      4: const _Matcher(
        path: ['bulletList', 'listItem', 'hardLineBreak'],
        text: null,
        marker: r'\',
      ),
      5: const _Matcher(
        path: ['bulletList', 'listItem'],
        text: null,
        marker: null,
      ),
      6: const _Matcher(
        path: ['bulletList', 'listItem'],
        text: 'b',
        marker: null,
      ),
      7: const _Matcher(
        path: [],
        text: null,
        marker: null,
      ),
    };

    for (var i = 0; i < text.length + 1; i++) {
      test('offset is $i', () {
        final whichElement = nodes.whichElement(i, text);
        final matcher = matchers[i]!;

        expect(whichElement.pathTypes, matcher.path);
        expect(whichElement.text?.text, matcher.text);
        expect(whichElement.marker?.text, matcher.marker);
      });
    }
  });
}

List<Node> toAst(String text) => Markdown().parse(text);

class _Matcher {
  const _Matcher({
    required this.path,
    required this.text,
    required this.marker,
  });

  final List<String> path;
  final String? text;
  final String? marker;
}
