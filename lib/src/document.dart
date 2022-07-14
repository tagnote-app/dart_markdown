// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'ast.dart';
import 'block_syntaxes/atx_heading_syntax.dart';
import 'block_syntaxes/blank_line_syntax.dart';
import 'block_syntaxes/blockquote_syntax.dart';
import 'block_syntaxes/fenced_blockquote_syntax.dart';
import 'block_syntaxes/fenced_code_block_syntax.dart';
import 'block_syntaxes/footnote_reference_syntax.dart';
import 'block_syntaxes/html_block_syntax.dart';
import 'block_syntaxes/indented_code_block_syntax.dart';
import 'block_syntaxes/link_reference_definition_syntax.dart';
import 'block_syntaxes/list_syntax.dart';
import 'block_syntaxes/paragraph_syntax.dart';
import 'block_syntaxes/setext_heading_syntax.dart';
import 'block_syntaxes/table_syntax.dart';
import 'block_syntaxes/thematic_break_syntax.dart';
import 'charcode.dart';
import 'extensions.dart';
import 'inline_syntaxes/autolink_extension_syntax.dart';
import 'inline_syntaxes/autolink_syntax.dart';
import 'inline_syntaxes/backslash_escape_syntax.dart';
import 'inline_syntaxes/code_span_syntax.dart';
import 'inline_syntaxes/emoji_syntax.dart';
import 'inline_syntaxes/emphasis_syntax.dart';
import 'inline_syntaxes/footnote_syntax.dart';
import 'inline_syntaxes/hard_line_break_syntax.dart';
import 'inline_syntaxes/highlight_syntax.dart';
import 'inline_syntaxes/image_syntax.dart';
import 'inline_syntaxes/link_syntax.dart';
import 'inline_syntaxes/raw_html_syntax.dart';
import 'inline_syntaxes/soft_line_break_syntax.dart';
import 'inline_syntaxes/superscript.dart';
import 'inline_syntaxes/text_syntax.dart';
import 'inline_syntaxes/tilde_syntax.dart';
import 'parsers/block_parser.dart';
import 'parsers/inline_parser.dart';
import 'syntax.dart';
import 'util.dart';

/// Maintains the context needed to parse a Markdown document.
class Document {
  final _blockSyntaxes = <BlockSyntax>{};
  final _inlineSyntaxes = <InlineSyntax>{};
  final bool hasCustomInlineSyntaxes;

  Iterable<BlockSyntax> get blockSyntaxes => _blockSyntaxes;

  Iterable<InlineSyntax> get inlineSyntaxes => _inlineSyntaxes;

  Document({
    bool enableAtxHeading = true,
    bool enableBlankLine = true,
    bool enableHeadingId = false,
    bool enableBlockquote = true,
    bool enableIndentedCodeBlock = true,
    bool enableFencedBlockquote = true,
    bool enableFencedCodeBlock = true,
    bool enableList = true,
    bool enableParagraph = true,
    bool enableSetextHeading = true,
    bool enableTable = true,
    bool enableHtmlBlock = true,
    bool enableLinkReferenceDefinition = true,
    bool enableThematicBreak = true,
    bool enableAutolinkExtension = true,
    bool enableAutolink = true,
    bool enableBackslashEscape = true,
    bool enableCodeSpan = true,
    bool enableEmoji = true,
    bool enableEmphasis = true,
    bool enableHardLineBreak = true,
    bool enableImage = true,
    bool enableLink = true,
    bool enableRawHtml = true,
    bool enableSoftLineBreak = true,
    bool enableStrikethrough = true,
    bool enableSubscript = false,
    bool enableSupscript = false,
    bool enableHighlight = false,
    bool enableFootnote = false,
    bool enableTaskList = false,
    Resolver? linkResolver,
    Resolver? imageLinkResolver,
    Iterable<Syntax> extensions = const [],
  }) : hasCustomInlineSyntaxes = extensions.any((e) => e is InlineSyntax) {
    for (final syntax in extensions) {
      if (syntax is BlockSyntax) {
        _blockSyntaxes.add(syntax);
      } else {
        _inlineSyntaxes.add(syntax as InlineSyntax);
      }
    }

    _blockSyntaxes.addAll([
      if (enableBlankLine) const BlankLineSyntax(),
      if (enableAtxHeading) AtxHeadingSyntax(enableHeadingId: enableHeadingId),
      if (enableSetextHeading)
        SetextHeadingSyntax(enableHeadingId: enableHeadingId),
      if (enableThematicBreak) const ThematicBreakSyntax(),
      if (enableList) ListSyntax(enableTaskList: enableTaskList),
      if (enableFencedBlockquote) const FencedBlockquoteSyntax(),
      if (enableBlockquote) const BlockquoteSyntax(),
      if (enableIndentedCodeBlock) const IndentedCodeBlockSyntax(),
      if (enableFencedCodeBlock) const FencedCodeBlockSyntax(),
      if (enableTable) const TableSyntax(),
      if (enableHtmlBlock) const HtmlBlockSyntax(),
      if (enableFootnote)
        FootnoteReferenceSyntax(enableParagraph: enableParagraph),
      if (enableLinkReferenceDefinition) LinkReferenceDefinitionSyntax(),
      ParagraphSyntax(disable: enableParagraph == false),
    ]);

    _inlineSyntaxes.addAll([
      // This first RegExp matches plain text to accelerate parsing. It's written
      // so that it does not match any prefix of any following syntaxes. Most
      // Markdown is plain text, so it's faster to match one RegExp per 'word'
      // rather than fail to match all the following RegExps at each non-syntax
      // character position.
      if (!hasCustomInlineSyntaxes)
        TextSyntax(r'[ \tA-Za-z0-9]*[A-Za-z0-9](?=\s)'),

      // We should be less aggressive in blowing past "words".
      if (hasCustomInlineSyntaxes) TextSyntax(r'[A-Za-z0-9]+(?=\s)'),

      if (enableHardLineBreak) HardLineBreakSyntax(),
      if (enableSoftLineBreak) SoftLineBreakSyntax(),
      if (enableBackslashEscape) BackslashEscapeSyntax(),
      // "*" surrounded by spaces is left alone.
      TextSyntax(r' \* ', startCharacter: $space),

      // "_" surrounded by spaces is left alone.
      TextSyntax(' _ ', startCharacter: $space),
      if (enableEmphasis) ...[
        // Parse "**strong**" and "*emphasis*" tags.
        EmphasisSyntax.asterisk(),

        // Parse "__strong__" and "_emphasis_" tags.
        EmphasisSyntax.underscore()
      ],
      if (enableFootnote) FootnoteSyntax(),
      if (enableAutolink) AutolinkSyntax(),
      if (enableAutolinkExtension) AutolinkExtensionSyntax(),
      if (enableCodeSpan) CodeSpanSyntax(),
      if (enableStrikethrough || enableSubscript)
        TildeSyntax(
          enableStrikethrough: enableStrikethrough,
          enableSubscript: enableSubscript,
        ),
      if (enableSupscript) CaretSyntax(enableSupscript: enableSupscript),
      if (enableHighlight) HighlightSyntax(),
      if (enableEmoji) EmojiSyntax(),
      if (enableLink) LinkSyntax(linkResolver: linkResolver),
      if (enableImage) ImageSyntax(linkResolver: imageLinkResolver),
      if (enableRawHtml) RawHtmlSyntax(),
    ]);
  }

  final linkReferences = <String, LinkReference>{};

  final _footnoteReferences = <String, Element>{};

  int _totalFootnote = 0;

  void addFootnoteReference(String label, Element element) {
    _footnoteReferences.putIfAbsent(label, () => element);
  }

  String? markFootnoteReference(String label) {
    final definition = _footnoteReferences[label];
    if (definition == null) {
      return null;
    }
    _footnoteReferences.remove(label);
    final number = (++_totalFootnote).toString();
    definition.attributes['number'] = number;
    return number;
  }

  /// Parses the given string of Markdown to a series of AST nodes.
  List<Node> parseLines(String text) {
    final nodes = BlockParser(stringToLines(text), this).parseLines();
    _parseInlineContent(nodes);
    return nodes;
  }

  void _parseInlineContent(List<Node> nodes, [Element? parentElement]) {
    final unparsedSegments = <UnparsedContent>[];

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node is UnparsedContent) {
        unparsedSegments.add(node);

        if (i + 1 == nodes.length || nodes[i + 1] is! UnparsedContent) {
          final inlineNodes = InlineParser(unparsedSegments, this).parse();
          for (var j = 0; j < inlineNodes.length; j++) {
            final inlineNode = inlineNodes[j];
            if (inlineNode is Element &&
                inlineNode.type == '_backslashEscape') {
              parentElement!.markers.addWithOrder(inlineNode.markers.first);
              inlineNodes.replaceRange(j, j + 1, inlineNode.children);
            }
          }
          // TODO(Zhiguang): double check the logic here.
          nodes.replaceRange(
            i - unparsedSegments.length + 1,
            i + 1,
            inlineNodes,
          );
          i -= unparsedSegments.length - inlineNodes.length;
        }
      } else if (node is Element) {
        _parseInlineContent(node.children, node);
      }
    }
  }
}

/// A [link reference
/// definition](http://spec.commonmark.org/0.28/#link-reference-definitions).
class LinkReference {
  /// The [link label](http://spec.commonmark.org/0.28/#link-label).
  ///
  /// Temporarily, this class is also being used to represent the link data for
  /// an inline link (the destination and title), but this should change before
  /// the package is released.
  final String label;

  /// The [link destination](http://spec.commonmark.org/0.28/#link-destination).
  final String destination;

  /// The [link title](http://spec.commonmark.org/0.28/#link-title).
  final String? title;

  /// Construct a new [LinkReference], with all necessary fields.
  ///
  /// If the parsed link reference definition does not include a title, use
  /// `null` for the [title] parameter.
  LinkReference(this.label, this.destination, this.title);
}
