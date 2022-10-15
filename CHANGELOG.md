## 3.1.0-dev

1. **BREAKING** Use dedicated name `fencedCodeBlock` for fenced code blocks and
   `indentedCodeBlock` for indented code blocks
   [PR#60](https://github.com/chenzhiguang/dart_markdown/pull/60).
2. **BREAKING** Use dedicated name `atxHeading` for ATX headings and
   `setextHeading` for Setext headings
   [PR#63](https://github.com/chenzhiguang/dart_markdown/pull/63).

## 3.0.0

1. Add `start` and `end` locations to AST `Element`.
   [PR#50](https://github.com/chenzhiguang/dart_markdown/pull/50).
2. **BREAKING** Rename `Document` to `Markdown` [PR#51][pr51].
3. **BREAKING** Rename `Document.parseLines` to `Markdown.parse`
   [PR#51][pr51].
4. **BREAKING** Remove `markdownToHtml()`, use `Markdown().parse().toHtml()`
   instead [PR#51][pr51].
5. **BREAKING** Remove `HtmlRenderer` from public [PR#51][pr51].

[pr51]: https://github.com/chenzhiguang/dart_markdown/pull/51

## 2.1.3

1. Fix a crash
   [Issue#45](https://github.com/chenzhiguang/dart_markdown/issues/45).

## 2.1.2

1. Update some links.
2. Update lint.

## 2.1.1

1. Add `forceTightList` option
   [PR#39](https://github.com/chenzhiguang/dart_markdown/pull/39).

## 2.1.0

1. Add `enableTagfilter` option
   [PR#34](https://github.com/chenzhiguang/dart_markdown/pull/34).
2. Update to Dart 2.17, update lints to 2.0.0
   [PR#35](https://github.com/chenzhiguang/dart_markdown/pull/35).

## 2.0.0

1. **BREAKING**: Add stricter rules to element parsers
   [Issue#29](https://github.com/chenzhiguang/dart_markdown/issues/29).

   _New rules:_

   - `BlockParser` can only return `BlockElement`.
   - `InlineParser` can only return `InlineObject`, which could be
     `InlineElement`, `Text` or `UnparsedContent`.
   - `InlineElement` can only have `InlineObject` as `children` elements.

2. Fix an issue when paragraph is disabled
   [Issue#27](https://github.com/chenzhiguang/dart_markdown/issues/27).

## 1.0.5

1. Add `kbd` support
   [PR#25](https://github.com/chenzhiguang/dart_markdown/pull/25).
2. **BREAKING**: Rename `enableSupscript` to `enableSuperscript`
   [PR#24](https://github.com/chenzhiguang/dart_markdown/pull/24).

## 1.0.4

1. Change element type `supscript` to `superscript`
   [PR#21](https://github.com/chenzhiguang/dart_markdown/pull/21).

## 1.0.3

1. Add sup script and sub script support
   [Issue#3](https://github.com/chenzhiguang/dart_markdown/issues/3).
2. Fix the conflict between footnote and image
   [PR#17](https://github.com/chenzhiguang/dart_markdown/pull/17).

## 1.0.2

1. Do not produce paragraph element in footnote reference when the paragraph is
   disabled
   [Issue#12](https://github.com/chenzhiguang/dart_markdown/issues/12).
2. Fix a task list item issue
   [Issue#13](https://github.com/chenzhiguang/dart_markdown/issues/13).

## 1.0.1

1. Add class name to task list item
   [Issue#6](https://github.com/chenzhiguang/dart_markdown/issues/6).
2. Improve footnote reference
   [Issue#9](https://github.com/chenzhiguang/dart_markdown/issues/9).

## 1.0.0

First version, refactored from
[dart-lang/markdown(5.0)](https://pub.dev/packages/markdown/versions/5.0.0)
