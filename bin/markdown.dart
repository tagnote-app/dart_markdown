// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_markdown/dart_markdown.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', negatable: false, help: 'Print help text and exit')
    ..addFlag('version', negatable: false, help: 'Print version and exit')
    ..addOption(
      'extension-set',
      allowed: ['none', 'CommonMark', 'GitHubFlavored', 'GitHubWeb'],
      defaultsTo: 'CommonMark',
      help: 'Specify a set of extensions',
      allowedHelp: {
        'none': 'No extensions; similar to Markdown.pl',
        'CommonMark': 'Parse like CommonMark Markdown (default)',
        'GitHubFlavored': 'Parse like GitHub Flavored Markdown',
        'GitHubWeb': 'Parse like GitHub\'s Markdown-enabled web input fields',
      },
    );
  final results = parser.parse(args);

  if (results['help'] as bool) {
    printUsage(parser);
    return;
  }

  if (results['version'] as bool) {
    print(version);
    return;
  }

  if (results.rest.length > 1) {
    printUsage(parser);
    exitCode = 1;
    return;
  }

  bool enableFencedCodeBlock = false;
  bool enableRawHtml = false;
  bool enableHeadingId = false;
  bool enableTable = false;
  bool enableStrikethrough = false;
  bool enableEmoji = false;
  bool enableAutolinkExtension = false;

  switch (results['extension-set']) {
    case 'commonMark':
      enableFencedCodeBlock = true;
      enableRawHtml = true;
      break;
    case 'GitHubFlavored':
      enableFencedCodeBlock = true;
      enableRawHtml = true;
      enableTable = true;
      enableStrikethrough = true;
      enableAutolinkExtension = true;
      break;
    case 'gitHubWeb':
      enableFencedCodeBlock = true;
      enableRawHtml = true;
      enableHeadingId = true;
      enableTable = true;
      enableStrikethrough = true;
      enableEmoji = true;
      enableAutolinkExtension = true;
      break;
  }

  final markdown = Markdown(
    enableFencedCodeBlock: enableFencedCodeBlock,
    enableRawHtml: enableRawHtml,
    enableHeadingId: enableHeadingId,
    enableTable: enableTable,
    enableStrikethrough: enableStrikethrough,
    enableEmoji: enableEmoji,
    enableAutolinkExtension: enableAutolinkExtension,
  );

  if (results.rest.length == 1) {
    // Read argument as a file path.
    final input = File(results.rest.first).readAsStringSync();
    print(markdown.parse(input).toHtml());
    return;
  }

  // Read from stdin.
  final buffer = StringBuffer();
  String? line;
  while ((line = stdin.readLineSync()) != null) {
    buffer.writeln(line);
  }
  print(markdown.parse(buffer.toString()).toHtml());
}

void printUsage(ArgParser parser) {
  print('''Usage: markdown.dart [options] [file]

Parse [file] as Markdown and print resulting HTML. If [file] is omitted,
use stdin as input.

By default, CommonMark Markdown will be parsed. This can be changed with
the --extensionSet flag.

${parser.usage}
''');
}
