# patchnotes.md

## v0.2.0 (2026-09-13)

The Wave variant ships: a second full port of upstream kanagawa.nvim's
wave theme, sharing the palette helper with Dragon. New theme file
`kanagawa-wave-nvim-theme.el`; enable with `(load-theme 'kanagawa-wave-nvim t)`.

- Spec first, per the roadmap's sequencing: `spec.md` gained the
  Wave-specific palette table (the sumi background ladder plus eight
  wave accents) and a Wave role mapping that resolves every Dragon face
  binding to its Wave value, so the contract covered the port before
  the code did.
- 14 new palette entries (`sumiInk0` through `sumiInk5`, `oniViolet`,
  `oniViolet2`, `crystalBlue`, `springViolet2`, `sakuraPink`,
  `surimiOrange`, `peachRed`, `boatYellow2`), hex and casing verbatim
  from upstream `colors.lua` and pinned byte-for-byte by the palette
  suite. The rest of Wave's pool was already in the palette from
  Dragon's borrowings.
- `kanagawa-wave-nvim-theme.el` maps the identical 483-face set as
  Dragon, including every Emacs 29+ treesit face and the Doom UI
  surfaces, with the Wave roles: strings `springGreen`, keywords
  `oniViolet`, types `waveAqua2`, function calls `crystalBlue`,
  parameters `oniViolet2`, punctuation `springViolet2`. Wave's
  ANSI/term row mirrors upstream `term[1..18]`; upstream's alacritty
  extra picks `#090618` for normal black and the theme follows
  `themes.lua` instead (recorded in the spec).
- Tests grow from 29 to 42: a Wave palette cross-check, Wave
  spot-checks mirroring the load-bearing Dragon set, and two
  structural invariants over both themes (every hex in every face spec
  is a palette member; no face is specified twice per theme).
- Fixed the spec drift the 2026-09-12 six-lens audit found: the Dragon
  face table's `line-number` row said `dragonBlack6` while the theme
  and test pin `dragonBlack5`; the spec row now matches (the document
  was what was wrong).
- README repairs, completing the partial 2026-09-05 URL fix: the Doom
  install recipe is now a proper github recipe instead of a literal
  local path, the vanilla snippet no longer hardcodes a home directory,
  the "What's NOT in v0.1" section is retitled and current, and the
  Layout section lists the Makefile, VERSION, CI workflow, and the
  guidance file.
- CI truth, owed a mention since the 2026-09-05 tick: the Actions
  matrix is Emacs 29.1, 29.4, and snapshot (snapshot allowed to fail).
  There has never been an Emacs 30 job, so earlier "29 + 30" wording
  was never accurate. CI now loads both themes.

## v0.1.4 — 2026-08-09

Roadmap correction, no theme change.

**v0.2's light/dark detection could not be built as written.** It loads the Wave
variant from `frame-background-mode`, and Wave is a v0.3 deliverable that does not
exist anywhere in the tree. The item has moved to v0.3 and now sits directly after
the Wave variant that it depends on.

Pulling Wave forward into v0.2 was the other option and was rejected: `spec.md`
carries only the roughly 23 Wave hexes that Dragon itself borrows, with no Wave
background ladder and no Wave face table, so building it is comparable in size to
the original Dragon port rather than a small addition. Detection is a two-line
function once a second variant exists, and is worth exactly nothing before then,
so it should follow Wave rather than lead it.


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
