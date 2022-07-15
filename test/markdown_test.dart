// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_markdown/dart_markdown.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() async {
  await testDirectory('original');

  // Block syntax extensions
  testFile(
    'extensions/fenced_code_blocks.unit',
  );
  testFile(
    'extensions/headers_with_ids.unit',
    enableHeadingId: true,
  );
  testFile(
    'extensions/setext_headers_with_ids.unit',
    enableHeadingId: true,
  );
  testFile(
    'extensions/tables.unit',
    enableTable: true,
  );
  testFile(
    'extensions/fenced_blockquotes.unit',
  );

  // Inline syntax extensions
  testFile(
    'extensions/emojis.unit',
  );
  testFile(
    'extensions/inline_html.unit',
  );
  testFile(
    'extensions/strikethrough.unit',
    enableStrikethrough: true,
  );
  testFile(
    'extensions/subscript.unit',
    enableSubscript: true,
    enableStrikethrough: true,
  );
  testFile(
    'extensions/supscript.unit',
    enableSubscript: true,
    enableSuperscript: true,
    enableStrikethrough: true,
  );
  testFile(
    'extensions/highlight.unit',
    enableHighlight: true,
  );
  testFile(
    'extensions/footnote_reference.unit',
    enableFootnote: true,
  );
  testFile(
    'extensions/footnote.unit',
    enableFootnote: true,
  );
  testFile(
    'extensions/task_list.unit',
    enableTaskList: true,
  );
  testFile(
    'extensions/kbd.unit',
    enableKbd: true,
    enableHtmlBlock: false,
    enableRawHtml: false,
  );

  await testDirectory('common_mark');
  await testDirectory('gfm');

  group('Corner cases', () {
    validateCore(
        'Incorrect Links',
        '''
5 Ethernet ([Music](
''',
        '<p>5 Ethernet ([Music](</p>');

    validateCore(
        'Escaping code block language',
        '''
```"/><a/href="url">arbitrary_html</a>
```
''',
        '<pre><code class="language-&quot;/&gt;&lt;a/href=&quot;url&quot;&gt;arbitrary_html&lt;/a&gt;"></code></pre>');

    validateCore(
        'Unicode ellipsis as punctuation',
        '''
"Connecting dot **A** to **B.**…"
''',
        '<p>&quot;Connecting dot <strong>A</strong> to <strong>B.</strong>…&quot;</p>');
  });

  group('Resolver', () {
    Node? nyanResolver(String text, [_]) => text.isEmpty
        ? null
        : Text.fromSpan(SourceFile.fromString(('~=[,,_${text}_,,]:3')).span(0));
    validateCore(
        'simple link resolver',
        '''
resolve [this] thing
''',
        '<p>resolve ~=[,,_this_,,]:3 thing</p>',
        linkResolver: nyanResolver);

    validateCore(
        'simple image resolver',
        '''
resolve ![this] thing
''',
        '<p>resolve ~=[,,_this_,,]:3 thing</p>',
        imageLinkResolver: nyanResolver);

    validateCore(
        'can resolve link containing inline tags',
        '''
resolve [*star* _underline_] thing
''',
        '<p>resolve ~=[,,_*star* _underline__,,]:3 thing</p>',
        linkResolver: nyanResolver);

    validateCore(
        'link resolver uses un-normalized link label',
        '''
resolve [TH  IS] thing
''',
        '<p>resolve ~=[,,_TH  IS_,,]:3 thing</p>',
        linkResolver: nyanResolver);

    validateCore(
        'can resolve escaped brackets',
        r'''
resolve [\[\]] thing
''',
        '<p>resolve ~=[,,_[]_,,]:3 thing</p>',
        linkResolver: nyanResolver);

    validateCore(
        'can choose to _not_ resolve something, like an empty link',
        '''
resolve [[]] thing
''',
        '<p>resolve ~=[,,_[]_,,]:3 thing</p>',
        linkResolver: nyanResolver);
  });

  group('Custom inline syntax', () {
    validateCore(
      'dart custom links',
      'links [are<foo>] awesome',
      '<p>links <a>are&lt;foo&gt;</a> awesome</p>',
      linkResolver: (String text, [String? _]) => Element(
        'link',
        children: [
          Text.fromSpan(
            SourceFile.fromString(text.replaceAll('<', '&lt;')).span(0),
          ),
        ],
      ),
    );

    // TODO(amouravski): need more tests here for custom syntaxes, as some
    // things are not quite working properly. The regexps are sometime a little
    // too greedy, I think.
  });
}
