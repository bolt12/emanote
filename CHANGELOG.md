# Revision history for emanote

## 0.8.2.0 (Unreleased)

- UI
  - Index pages are no longer marked as 'experimental'
  - Add external link icon to external links (this behaviour is customizable). [\#189](https://github.com/EmaApps/emanote/pull/189)
  - `js.mermaid` snippet uses the "module" script tag approach, which is added to end of `<body>`. See [here](https://mermaid-js.github.io/mermaid/#/n00b-gettingStarted?id=_3-calling-the-javascript-api). 
- Configuration
  - Add `page.bodyHtml` option to inject custom HTML at the end of `<body>` tag.
- Dev
  - Move test sources to Cabal's `other-modules` so they are not exposed.
  - Wikilink parser is now a separate library: https://github.com/srid/commonmark-wikilink

## 0.8.0.0 (2022-11-03)

Initial release.