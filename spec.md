# spec.md — kanagawa-dragon-nvim-emacs

The contract for this theme family. If a face mapping or palette value
disagrees with this document, the document is authoritative; fix the code.

## Goals

1. **Faithful to nvim's Kanagawa themes.** Side-by-side a Java buffer in
   Doom Emacs and the same buffer in nvim with `kanagawa-dragon` (or
   `kanagawa-wave`) should feel like the same theme, not "two theme
   families that share a name."
2. **Vanilla-Emacs portable.** Built on `deftheme`, no `doom-themes`
   macro dependency. Doom-specific faces are mapped, but loading in
   vanilla Emacs must not error.
3. **Treesit-correct.** All Emacs 29+ `font-lock-*` faces introduced for
   tree-sitter (`font-lock-function-call-face`,
   `font-lock-operator-face`, `font-lock-property-use-face`, etc.) are
   mapped. Without these, modern Java/Python/Rust buffers collapse to
   default fg.

## Non-goals (v0.1)

- Wave or Lotus variants. (Superseded in part: Wave shipped in v0.2.0.
  Lotus, the light variant, remains out of scope.)
- Light-mode toggle.
- Auto-detect terminal vs GUI palette.
- Compatibility shims for Emacs <29.

## Palette

Names match the upstream nvim source verbatim
(`~/.local/share/nvim/lazy/kanagawa.nvim/lua/kanagawa/colors.lua`) so cross-
referencing is mechanical. Hex values are bit-for-bit identical.

### Dragon-specific palette

| Name           | Hex       | Role                               |
|----------------|-----------|------------------------------------|
| `dragonBlack0` | `#0d0c0c` | float bg                           |
| `dragonBlack1` | `#12120f` | bg-dim, bg-m2                      |
| `dragonBlack2` | `#1D1C19` | bg-m1                              |
| `dragonBlack3` | `#181616` | **default bg**                     |
| `dragonBlack4` | `#282727` | bg-p1, bg-gutter (hl-line)         |
| `dragonBlack5` | `#393836` | bg-p2                              |
| `dragonBlack6` | `#625e5a` | whitespace, nontext                |
| `dragonWhite`  | `#c5c9c5` | **default fg**                     |
| `dragonGreen`  | `#87a987` | terminal bright-green              |
| `dragonGreen2` | `#8a9a7b` | **strings**, terminal green        |
| `dragonPink`   | `#a292a3` | **numbers**, terminal magenta      |
| `dragonOrange` | `#b6927b` | constants                          |
| `dragonOrange2`| `#b98d7b` | extended palette 2                 |
| `dragonGray`   | `#a6a69c` | parameters, terminal bright-black  |
| `dragonGray2`  | `#9e9b93` | punctuation                        |
| `dragonGray3`  | `#7a8382` | special / non-text emphasis        |
| `dragonBlue2`  | `#8ba4b0` | **functions**, terminal blue       |
| `dragonViolet` | `#8992a7` | **keywords**, statements           |
| `dragonRed`    | `#c4746e` | **operators**, preproc, regex      |
| `dragonAqua`   | `#8ea4a2` | **types**, terminal cyan           |
| `dragonAsh`    | `#737c73` | **comments**                       |
| `dragonTeal`   | `#949fb5` | special-1                          |
| `dragonYellow` | `#c4b28a` | identifiers                        |

### Wave-specific palette

| Name            | Hex       | Role                               |
|-----------------|-----------|------------------------------------|
| `sumiInk0`      | `#16161D` | bg-m3, float bg                    |
| `sumiInk1`      | `#181820` | bg-dim, bg-m2                      |
| `sumiInk2`      | `#1a1a22` | bg-m1                              |
| `sumiInk3`      | `#1F1F28` | **default bg** (Wave)              |
| `sumiInk4`      | `#2A2A37` | bg-p1, bg-gutter (hl-line)         |
| `sumiInk5`      | `#363646` | bg-p2                              |
| `oniViolet`     | `#957FB8` | **keywords**, statements           |
| `oniViolet2`    | `#b8b4d0` | parameters                         |
| `crystalBlue`   | `#7E9CD8` | **functions**                      |
| `springViolet2` | `#9CABCA` | punctuation                        |
| `sakuraPink`    | `#D27E99` | **numbers**                        |
| `surimiOrange`  | `#FFA066` | constants                          |
| `peachRed`      | `#FF5D62` | special-3                          |
| `boatYellow2`   | `#C0A36E` | **operators**, regex               |

### Shared palette (used by both variants)

| Name           | Hex       | Role                                  |
|----------------|-----------|---------------------------------------|
| `dragonBlue`   | `#658594` | diag-info                             |
| `fujiWhite`    | `#DCD7BA` | pmenu fg                              |
| `oldWhite`     | `#C8C093` | fg-dim, float fg, terminal white      |
| `fujiGray`     | `#727169` | reserved (unused in Dragon mapping)   |
| `katanaGray`   | `#717C7C` | deprecated                            |
| `sumiInk6`     | `#54546D` | float border                          |
| `waveBlue1`    | `#223249` | bg_visual (region), pmenu bg          |
| `waveBlue2`    | `#2D4F67` | bg_search, pmenu selection            |
| `waveAqua1`    | `#6A9589` | diag-hint                             |
| `waveAqua2`    | `#7AA89F` | terminal bright-cyan                  |
| `waveRed`      | `#E46876` | terminal bright-red                   |
| `springGreen`  | `#98BB6C` | diag-ok                               |
| `springBlue`   | `#7FB4CA` | terminal bright-blue                  |
| `springViolet1`| `#938AA9` | terminal bright-magenta               |
| `carpYellow`   | `#E6C384` | terminal bright-yellow                |
| `samuraiRed`   | `#E82424` | diag-error                            |
| `roninYellow`  | `#FF9E3B` | diag-warn                             |
| `winterRed`    | `#43242B` | diff-delete bg                        |
| `winterGreen`  | `#2B3328` | diff-add bg                           |
| `winterYellow` | `#49443C` | diff-text bg                          |
| `winterBlue`   | `#252535` | diff-change bg                        |
| `autumnRed`    | `#C34043` | vcs-removed                           |
| `autumnGreen`  | `#76946A` | vcs-added                             |
| `autumnYellow` | `#DCA561` | vcs-changed                           |

## Face mapping

Each face cites the nvim semantic role from `themes.lua`'s `dragon` block
(`syn.*`, `ui.*`, `diag.*`, `diff.*`, `vcs.*`, `term[N]`). The tables in
this section are the Dragon mapping; the Wave variant sets the identical
face set with the Wave role values from `themes.lua`'s `wave` block (see
"Wave role mapping" at the end of this section).

### Core UI

| Face                       | Color                  | Origin           |
|----------------------------|------------------------|------------------|
| `default`                  | `dragonWhite` on `dragonBlack3` | `ui.fg/bg`     |
| `cursor`                   | bg `dragonWhite`       | nvim cursor      |
| `region`                   | bg `waveBlue1`         | `ui.bg_visual`   |
| `secondary-selection`      | bg `waveBlue2`         | `ui.bg_search`   |
| `hl-line`                  | bg `dragonBlack4`      | `ui.bg_gutter`   |
| `fringe`                   | bg `dragonBlack3`, fg `dragonBlack6` | derived |
| `line-number`              | fg `dragonBlack5`      | derived          |
| `line-number-current-line` | fg `dragonWhite` bold  | derived          |
| `vertical-border`          | fg `dragonBlack4`      | derived          |
| `window-divider`           | fg `dragonBlack4`      | derived          |
| `match`                    | bg `waveBlue2`         | `ui.bg_search`   |
| `link` / `custom-link`     | fg `dragonBlue2` underline | `syn.fun`    |
| `error`                    | fg `samuraiRed`        | `diag.error`     |
| `warning`                  | fg `roninYellow`       | `diag.warning`   |
| `success`                  | fg `springGreen`       | `diag.ok`        |

### Syntax (font-lock + treesit)

Includes the Emacs 29+ tree-sitter additions (`*-call-face`,
`*-use-face`, `operator-face`, `number-face`, `property-*-face`,
`bracket/delimiter/punctuation`).

| Face                                | Color              | Origin           |
|-------------------------------------|--------------------|------------------|
| `font-lock-comment-face`            | `dragonAsh` italic | `syn.comment`    |
| `font-lock-comment-delimiter-face`  | `dragonAsh` italic | `syn.comment`    |
| `font-lock-doc-face`                | `dragonAsh` italic | `syn.comment`    |
| `font-lock-doc-markup-face`         | `dragonGray3`      | derived          |
| `font-lock-string-face`             | `dragonGreen2`     | `syn.string`     |
| `font-lock-keyword-face`            | `dragonViolet`     | `syn.keyword`, italic |
| `font-lock-builtin-face`            | `dragonViolet`     | `syn.statement`, italic |
| `font-lock-constant-face`           | `dragonOrange`     | `syn.constant`   |
| `font-lock-number-face`             | `dragonPink`       | `syn.number`     |
| `font-lock-type-face`               | `dragonAqua`       | `syn.type`       |
| `font-lock-function-name-face`      | `dragonBlue2`      | `syn.fun` (def)  |
| `font-lock-function-call-face`      | `dragonBlue2`      | `syn.fun` (call) |
| `font-lock-variable-name-face`      | `dragonYellow`     | `syn.identifier` |
| `font-lock-variable-use-face`       | `dragonGray`       | `syn.parameter`  |
| `font-lock-property-name-face`      | `dragonYellow`     | `syn.identifier` |
| `font-lock-property-use-face`       | `dragonYellow`     | `syn.identifier` |
| `font-lock-operator-face`           | `dragonRed`        | `syn.operator`   |
| `font-lock-preprocessor-face`       | `dragonRed`        | `syn.preproc`    |
| `font-lock-regexp-face`             | `dragonRed`        | `syn.regex`      |
| `font-lock-regexp-grouping-backslash` | `dragonRed`      | `syn.regex`      |
| `font-lock-regexp-grouping-construct` | `dragonRed`      | `syn.regex`      |
| `font-lock-bracket-face`            | `dragonGray2`      | `syn.punct`      |
| `font-lock-delimiter-face`          | `dragonGray2`      | `syn.punct`      |
| `font-lock-punctuation-face`        | `dragonGray2`      | `syn.punct`      |
| `font-lock-misc-punctuation-face`   | `dragonGray2`      | `syn.punct`      |
| `font-lock-escape-face`             | `dragonRed`        | `syn.special2`   |
| `font-lock-negation-char-face`      | `dragonRed`        | `syn.special3`   |
| `font-lock-warning-face`            | `roninYellow`      | `diag.warning`   |

### Diff / VCS

`diff-added`, `diff-removed`, `diff-changed` use `winterGreen`,
`winterRed`, `winterBlue` backgrounds with `autumnGreen`, `autumnRed`,
`autumnYellow` foregrounds where text fg is needed.

`diff-hl-margin-{insert,delete,change}` and
`vc-gutter`/`git-gutter:{added,deleted,modified}` use `autumn*` for fg.

### Doom UI (loaded if Doom face symbols are bound)

| Face                            | Color                                   |
|---------------------------------|-----------------------------------------|
| `doom-modeline-bar`             | bg `dragonViolet`                       |
| `doom-modeline-buffer-file`     | `dragonAqua` bold                       |
| `doom-modeline-buffer-modified` | `dragonOrange` bold                     |
| `doom-modeline-project-dir`     | `dragonBlue2` bold                      |
| `doom-modeline-info`            | `dragonGreen2`                          |
| `doom-modeline-warning`         | `roninYellow`                           |
| `doom-modeline-urgent`          | `samuraiRed`                            |
| `doom-modeline-evil-normal-state` | `dragonAqua`                          |
| `doom-modeline-evil-insert-state` | `dragonGreen2`                        |
| `doom-modeline-evil-visual-state` | `dragonOrange`                        |
| `doom-modeline-evil-replace-state` | `dragonRed`                          |
| `solaire-default-face`          | bg `dragonBlack2` (slightly darker)     |
| `solaire-hl-line-face`          | bg `dragonBlack4`                       |
| `solaire-mode-line-face`        | bg `dragonBlack0`                       |

### Org

Headings step by hue, not by height (header-height variation is
opinionated and not part of nvim's flavor):

| Face          | Color           |
|---------------|-----------------|
| `org-level-1` | `dragonViolet`  |
| `org-level-2` | `dragonBlue2`   |
| `org-level-3` | `dragonAqua`    |
| `org-level-4` | `dragonGreen2`  |
| `org-level-5` | `dragonYellow`  |
| `org-level-6` | `dragonOrange`  |
| `org-level-7` | `dragonPink`    |
| `org-level-8` | `dragonRed`     |
| `org-block`   | bg `dragonBlack1` |
| `org-todo`    | `dragonOrange` bold |
| `org-done`    | `dragonAsh`     |
| `org-date`    | `dragonAqua`    |
| `org-link`    | `dragonBlue2` underline |

### Terminal / ANSI

Mirrors nvim's `term[1..18]` Dragon mapping verbatim
(see palette table for which color goes where): `term[1..8]` are the
normal ANSI colors, `term[9..16]` the brights, and `term[17..18]` the
extended colors (`dragonOrange` / `dragonOrange2`, which is why
`dragonOrange2` exists in the palette despite no face using it).

The Emacs surfaces carry the mapping: `ansi-color-*` and
`term-color-*` for the 16 palette entries, and vterm's
`vterm-color-default`, `vterm-color-{black..white}`, and the eight
`vterm-color-bright-*` faces resolve from the same rows (the brights
are `term[9..16]`; bright faces shipped v0.2.1). vterm reads each
color face's background as its palette entry, so the vterm color
faces set foreground and background to the same hex.

### Wave role mapping

`kanagawa-wave-nvim-theme.el` (shipped v0.2.0) sets every face in the
tables above; this role table is where each of Dragon's bindings
resolves for Wave. Values come verbatim from `themes.lua`'s `wave`
block. The diagnostics, diff, and vcs roles are identical to Dragon's
(`samuraiRed`, `roninYellow`, `dragonBlue`, `springGreen`; `winter*`
diff backgrounds; `autumn*` gutter foregrounds).

| Role               | Wave value      | Dragon value (for contrast)  |
|--------------------|-----------------|------------------------------|
| `ui.fg`            | `fujiWhite`     | `dragonWhite`                |
| `ui.fg_dim`        | `oldWhite`      | `oldWhite`                   |
| `ui.bg_dim`        | `sumiInk1`      | `dragonBlack1`               |
| `ui.bg_m3`         | `sumiInk0`      | `dragonBlack0`               |
| `ui.bg_m2`         | `sumiInk1`      | `dragonBlack1`               |
| `ui.bg_m1`         | `sumiInk2`      | `dragonBlack2`               |
| `ui.bg`            | `sumiInk3`      | `dragonBlack3`               |
| `ui.bg_p1`         | `sumiInk4`      | `dragonBlack4`               |
| `ui.bg_p2`         | `sumiInk5`      | `dragonBlack5`               |
| `ui.bg_gutter`     | `sumiInk4`      | `dragonBlack4`               |
| `ui.special`       | `springViolet1` | `dragonGray3`                |
| `ui.nontext`       | `sumiInk6`      | `dragonBlack6`               |
| `ui.whitespace`    | `sumiInk6`      | `dragonBlack6`               |
| `ui.bg_visual`     | `waveBlue1`     | `waveBlue1`                  |
| `ui.bg_search`     | `waveBlue2`     | `waveBlue2`                  |
| `ui.pmenu.bg`      | `waveBlue1`     | `waveBlue1`                  |
| `ui.pmenu.bg_sel`  | `waveBlue2`     | `waveBlue2`                  |
| `ui.float.bg`      | `sumiInk0`      | `dragonBlack0`               |
| `ui.float.border`  | `sumiInk6`      | `sumiInk6`                   |
| `syn.string`       | `springGreen`   | `dragonGreen2`               |
| `syn.number`       | `sakuraPink`    | `dragonPink`                 |
| `syn.constant`     | `surimiOrange`  | `dragonOrange`               |
| `syn.identifier`   | `carpYellow`    | `dragonYellow`               |
| `syn.parameter`    | `oniViolet2`    | `dragonGray`                 |
| `syn.fun`          | `crystalBlue`   | `dragonBlue2`                |
| `syn.statement`    | `oniViolet`     | `dragonViolet`               |
| `syn.keyword`      | `oniViolet`     | `dragonViolet`               |
| `syn.operator`     | `boatYellow2`   | `dragonRed`                  |
| `syn.preproc`      | `waveRed`       | `dragonRed`                  |
| `syn.type`         | `waveAqua2`     | `dragonAqua`                 |
| `syn.regex`        | `boatYellow2`   | `dragonRed`                  |
| `syn.deprecated`   | `katanaGray`    | `katanaGray`                 |
| `syn.comment`      | `fujiGray`      | `dragonAsh`                  |
| `syn.punct`        | `springViolet2` | `dragonGray2`                |
| `syn.special1`     | `springBlue`    | `dragonTeal`                 |
| `syn.special2`     | `waveRed`       | `dragonRed`                  |
| `syn.special3`     | `peachRed`      | `dragonRed`                  |

Derived rows follow the same derivations as Dragon: the `line-number`
foreground is `ui.bg_p2` (`sumiInk5`), Org headings step by hue through
the Wave accent ladder (`oniViolet`, `crystalBlue`, `waveAqua2`,
`springGreen`, `carpYellow`, `surimiOrange`, `sakuraPink`,
`boatYellow2`), and the Doom/solaire surfaces ride the Wave ladder the
same way the Dragon tables ride the Dragon ladder.

Wave's ANSI / term colors mirror `term[1..18]` from the `wave` block.
Upstream's alacritty extra (`extras/alacritty/kanagawa_wave.toml`)
picks `#090618` for normal black; the theme follows `themes.lua`
(`sumiInk0`) instead, which is what nvim actually renders. Every other
slot agrees with the alacritty extra.

## Conformance

The theme is conformant when:

1. Every palette entry in this spec exists in `kanagawa-dragon-nvim.el`
   with the exact hex shown.
2. Every face mapping above is set in `kanagawa-dragon-nvim-theme.el`,
   and `kanagawa-wave-nvim-theme.el` resolves the same face set through
   the Wave role mapping.
3. `tests/test-palette.el` and `tests/test-faces.el` pass under
   `emacs -Q --batch`.
4. Visual eyeballing of `tests/sample.java` (Java tree-sitter,
   `treesit-font-lock-level 4`) matches the upstream nvim screenshot
   for the same file, each variant against its own nvim counterpart.
