# patchnotes.md

## v0.1.3 — 2026-08-08

Tests only; no face or palette change. The v0.2 coverage-extension item
lands: `tests/test-faces.el` grows from 33 to 182 unique asserted faces
(24 tests, up from 11), sweeping every previously-untested family the theme
defines: the full `font-lock-*` and `tree-sitter-hl-face:*` namespaces, the
whole `lsp-face-semhl-*` token family, org beyond level 4, doom-modeline,
the diff/vcs winter-background and autumn-foreground split, magit, the
completion stack (vertico/corfu/orderless/marginalia/which-key/company),
the full nine-depth rainbow-delimiters ladder, dired, the bright ANSI row
with its term/vterm mirrors, the core-UI remainder, and the
flycheck/flymake fringes. Every expectation is read off the theme's
binding table, so a drifted binding or a typo'd face entry fails by name
rather than silently shipping. `make test` 29/29 on Emacs 30.2;
`make compile` clean under warnings-as-errors.

## v0.1.2 — 2026-05-14

Adds an opt-in helper that fixes a long-standing lsp-mode quirk where
semantic-token *modifiers* override the base token colour. No theme
face change; pure new API.

- New: `kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed`. By default,
  `lsp-mode` maps modifiers like `declaration` and `readonly` to
  *colored* type faces in `lsp-semantic-token-modifier-faces`
  (`lsp-face-semhl-interface`, `lsp-face-semhl-constant`, etc.). Face
  composition prepends modifier faces, so the modifier's colour wins
  over the base. For Java that means every field, method, and local
  declaration loses its base colour when jdtls attaches. The helper
  repoints the six bleeding entries at a no-op face. Call it once
  inside `with-eval-after-load 'lsp-semantic-tokens` — see the README
  for the snippet.
- New: `kanagawa-dragon-nvim-lsp-modifier-noop` (empty face) and
  `kanagawa-dragon-nvim-lsp-bleeding-modifiers` (constant list of the
  six modifiers the helper rebinds: declaration, readonly, abstract,
  async, modification, documentation).
- ERT regression test added (`kdn-helpers/lsp-modifier-bleed-rebinds-bleeders`)
  that simulates the lsp-mode alist and verifies the helper rebinds
  the bleeding entries while leaving non-bleeding ones alone — runs
  without lsp-mode installed.

## v0.1.1 — 2026-05-14

Bugfix release. One face mapping correction; no palette or API change.

- Fix `lsp-face-semhl-variable` collapsing to default foreground. The
  face was bound to `fg` (`dragonWhite`); when `lsp-mode` attached and
  overlaid semantic tokens on a tree-sitter pass, every variable name
  in the buffer flattened into the surrounding text. Now routes to
  `s-ident` (`dragonYellow`), matching `font-lock-variable-name-face`
  so the LSP overlay and the tree-sitter pass agree.
- ERT regression test added (`kdn-faces/lsp-semhl-variable-not-flattened`)
  with a family check against `lsp-face-semhl-property` and
  `lsp-face-semhl-member` so the three identifier-shaped LSP faces
  can't silently drift apart.

## v0.1.0 — 2026-05-10

First faithful render. Initial release.

- Full Dragon palette ported from `kanagawa.nvim` byte-for-byte; names
  match upstream (`dragonBlack3`, `dragonGreen2`, etc.) so the spec can
  be cross-referenced mechanically.
- All Emacs 29+ tree-sitter `font-lock-*` faces are mapped — fixes the
  "Java code looks monochrome at `treesit-font-lock-level 4`" gap that
  motivated the project.
- Doom-aware: `doom-modeline-*`, `solaire-mode`, `doom-dashboard-*`
  faces render correctly when those packages are loaded; loading the
  theme in vanilla Emacs is a no-op for those bindings.
- Org and org-modern surfaces tinted with the Dragon palette; headings
  step by hue rather than height.
- ANSI / term colors mirror `extras/alacritty/kanagawa_dragon.toml`
  from upstream verbatim.
- Tests: ERT palette integrity, ERT representative face attributes,
  visual sample buffers for Java / Python / Emacs Lisp.
