# patchnotes.md

## v0.2.1 (2026-09-15)

Maintenance release from THE FINAL BLITZ: the masked CI canary is
restored, vterm's bright colors are themed, the family's core contract
is finally enforced, and the integration surfaces rendered daily no
longer fall through to default Emacs colors. The suite grows from 42
to 47 tests.

- CI: the snapshot leg had been permanently red since at least
  2026-08-09 with `continue-on-error` masking it at run level, so the
  Emacs 31 canary gave zero signal. Two real breakages fixed: the
  package now has a `defgroup` and the no-op LSP face names it (a
  defface missing its containing group is a hard error on Emacs 31),
  and `when-let` (obsolete as of 31.1) became `when-let*`.
  `continue-on-error` is dropped entirely. The same workflow touch
  SHA-pinned `purcell/setup-emacs` at v8.0 and `actions/checkout` at
  v7.0.1, added a read-only permissions block, `v*` tag triggers, the
  missing Emacs 30 job (30.2), and `make load` / `make load-wave`
  replacing CI's inline evals; `make clean` also removes `*.eln`.
  First run on the fixed workflow: snapshot green.
- Both themes map the eight `vterm-color-bright-*` faces from the
  existing bright ANSI bindings (upstream `term[9..16]`), so bright
  SGR (90-97 / 100-107) no longer renders unthemed.
- New test `kdn-faces/dragon-and-wave-face-sets-identical` enforces
  the family's core contract (spec Conformance rule 2): Wave sets the
  identical face set Dragon sets. Hand-verified at the 2026-09-13
  audit but enforced by nothing until now; it generalizes to Lotus
  unchanged.
- Theme palette lookups now route through the erroring
  `kanagawa-dragon-nvim-color`, so a typo'd palette symbol fails
  loudly at load time instead of silently rendering unspecified.
- New test `kdn-palette/version-headers-match` pins the three `.el`
  file headers to the `kanagawa-dragon-nvim-version` defconst, which
  an existing test pins to the `VERSION` file: five places, one
  number, actually enforced.
- Comment truth: the shared-palette wording no longer overclaims
  (fujiWhite, fujiGray, and waveAqua1 are Wave-only), the
  flycheck-posframe comment describes the posframe popup it actually
  colors, and the modifier-bleed rationale is corrected everywhere it
  was wrong (helper docstring, README, CLAUDE.md): four of the five
  non-bleeding modifiers do inherit colored lsp-mode faces; they
  don't bleed because the themes pin those faces to
  `inherit unspecified`, deprecated keeping a deliberate
  strike-through.
- Dragon's `solaire-default-face` background is now `dragonBlack1`
  (#12120f, upstream's bg_dim) instead of `dragonBlack2`, which had
  been lighter than the default bg: Brandon's call (2026-09-15), so
  Dragon and Wave now darken real buffers alike. The spec row and the
  test (renamed to `kdn-faces/solaire-bg-distinct-from-default`) tell
  the true story.
- Integration face pass: 69 rows per theme for avy, consult, embark,
  transient, ediff, and smerge, spec section first, identical face
  set in both variants (the equality test now guards 560 = 560), with
  spot-checks per variant. Faces that inherit themed parents
  (`transient-argument`/`-value` via `font-lock-string-face`, the
  inactive/inapt family via `shadow`, the `transient-key-*` flavours
  via `transient-key`) are deliberately unmapped.
- New `tests/sample.rs` joins the visual eyeball buffers, so the
  acceptance check works in `rust-ts-mode` too; it compiles and runs
  (verified with rustc).
- MELPA preparation without the flip: `package-lint` is clean except
  one documented exception (the new family-neutral alias
  `kanagawa-nvim-neutralize-lsp-modifier-bleed`, kept so Wave-only
  configs need not call a Dragon-named function; the prefixed name
  stays canonical and MELPA's prefix rule would drop the alias at
  submission time). The recipe is drafted in the README, and the
  GitHub description and topics now cover both variants.
- Audit hygiene: the LICENSE appendix credits Dragon and Wave; spec
  cites upstream by repo path instead of a machine path; three
  pre-rule em-dashes are gone from the README; the four
  `lsp-face-semhl` rows no current lsp-mode defface defines
  (`typeparameter`, `enummember`, `declaration`, `readonly`) are
  annotated as harmless pins; the `.claude/` relic is deleted and
  gitignored; and the two unused v0.1.0-era screenshots (83% of
  tracked bytes) are removed from `assets/` (Brandon's call; git
  history keeps the blobs).

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
