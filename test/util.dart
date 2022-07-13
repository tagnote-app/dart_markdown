// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:isolate';

import 'package:dart_markdown/dart_markdown.dart';
import 'package:io/ansi.dart' as ansi;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/expected_output.dart';

/// Removes the last line feed of each test case from "*.unit" files.
String _removeLineFeed(String text) =>
    text.endsWith('\n') ? text.substring(0, text.length - 1) : text;

/// Runs tests defined in "*.unit" files inside directory [name].
Future<void> testDirectory(String name) async {
  await for (final dataCase in dataCasesUnder(testDirectory: name)) {
    final description =
        '${dataCase.directory}/${dataCase.file}.unit ${dataCase.description}';
    bool enableTable = false;
    bool enableStrikethrough = false;
    bool enableAutolinkExtension = false;

    if (dataCase.file.endsWith('_extension')) {
      final syntaxName = dataCase.file.substring(
        0,
        dataCase.file.lastIndexOf('_extension'),
      );
      if (syntaxName == 'tables') {
        enableTable = true;
      } else if (syntaxName == 'strikethrough') {
        enableStrikethrough = true;
      } else if (syntaxName == 'autolinks') {
        enableAutolinkExtension = true;
      }
    }

    validateCore(
      description,
      dataCase.input,
      _removeLineFeed(dataCase.expectedOutput),
      enableTable: enableTable,
      enableStrikethrough: enableStrikethrough,
      enableAutolinkExtension: enableAutolinkExtension,
    );
  }
}

Future<String> get markdownPackageRoot async {
  final packageUri = Uri.parse('package:dart_markdown/dart_markdown.dart');
  final isolateUri = await Isolate.resolvePackageUri(packageUri);
  return p.dirname(p.dirname(isolateUri!.toFilePath()));
}

void testFile(
  String file, {
  bool enableTable = false,
  bool enableStrikethrough = false,
  bool enableAutolinkExtension = false,
  bool enableHeadingId = false,
  bool enableHighlight = false,
  bool enableFootnote = false,
  bool enableLinkReferenceDefinition = true,
  bool enableTaskList = false,
}) async {
  final directory = p.join(await markdownPackageRoot, 'test');
  for (final dataCase in dataCasesInFile(path: p.join(directory, file))) {
    final description =
        '${dataCase.directory}/${dataCase.file}.unit ${dataCase.description}';
    validateCore(
      description,
      dataCase.input,
      _removeLineFeed(dataCase.expectedOutput),
      enableTable: enableTable,
      enableStrikethrough: enableStrikethrough,
      enableAutolinkExtension: enableAutolinkExtension,
      enableHeadingId: enableHeadingId,
      enableHighlight: enableHighlight,
      enableFootnote: enableFootnote,
      enableLinkReferenceDefinition: enableLinkReferenceDefinition,
      enableTaskList: enableTaskList,
    );
  }
}

void validateCore(
  String description,
  String markdown,
  String html, {
  Resolver? linkResolver,
  Resolver? imageLinkResolver,
  bool enableTable = false,
  bool enableStrikethrough = false,
  bool enableAutolinkExtension = false,
  bool enableHeadingId = false,
  bool enableHighlight = false,
  bool enableFootnote = false,
  bool enableLinkReferenceDefinition = true,
  bool enableTaskList = false,
}) {
  test(description, () {
    final result = markdownToHtml(
      markdown,
      linkResolver: linkResolver,
      imageLinkResolver: imageLinkResolver,
      enableTable: enableTable,
      enableStrikethrough: enableStrikethrough,
      enableAutolinkExtension: enableAutolinkExtension,
      enableHeadingId: enableHeadingId,
      enableHighlight: enableHighlight,
      enableFootnote: enableFootnote,
      enableLinkReferenceDefinition: enableLinkReferenceDefinition,
      enableTaskList: enableTaskList,
    );

    markdownPrintOnFailure(markdown, html, result);

    expect(result, html);
  });
}

String whitespaceColor(String input) => input
    .replaceAll(' ', ansi.lightBlue.wrap('·')!)
    .replaceAll('\t', ansi.backgroundDarkGray.wrap('\t')!);

void markdownPrintOnFailure(String markdown, String expected, String actual) {
  printOnFailure("""
INPUT:
'''r
${whitespaceColor(markdown)}'''            
           
EXPECTED:
'''r
${whitespaceColor(expected)}'''

GOT:
'''r
${whitespaceColor(actual)}'''
""");
}
