# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A faithful Emacs port of the **Dragon** variant of `kanagawa.nvim` (rebelot). Vanilla `deftheme`, no `doom-themes` macro dependency. Emacs 29.1+ only. MIT-licensed. Currently v0.1.2, Dragon-only (no Wave/Lotus yet), not yet published to MELPA.

The motivating problem: the existing `kanagawa-themes` Emacs package has the palette right but does not map the **Emacs 29+ tree-sitter `font-lock-*` faces** (`font-lock-function-call-face`, `font-lock-operator-face`, `font-lock-property-use-face`, bracket/delimiter/punctuation, etc.). At `treesit-font-lock-level 4` modern code modes collapse to default foreground. This theme maps every face in the spec so a Java buffer in Doom Emacs looks the way it does in nvim.

## Build and test

```sh
make test       # ERT under emacs -Q --batch: palette + face mapping
make compile    # byte-compile with byte-compile-error-on-warn=t
make clean      # rm *.elc tests/*.elc
```

The `EMACS` make variable overrides the binary (`make EMACS=/path/to/emacs test`). Tests run under `emacs -Q --batch`, so a passing run on a contributor's machine means the same on yours; no user config is touched.

Run a single ERT test by selector:

```sh
emacs -Q --batch -L . \
  -l tests/test-palette.el -l tests/test-faces.el \
  --eval '(ert-run-tests-batch-and-exit "kdn-faces/syntax-strings-keywords-types")'
```

The selector is a regexp over deftest names (the `kdn-palette/*`, `kdn-faces/*`, `kdn-helpers/*` namespaces).

## Architecture

Two source files, one role each. Keep them separate; don't fold the palette into the theme file or vice versa.

### `kanagawa-dragon-nvim.el` — palette + helpers, no theme activation

- Exports `kanagawa-dragon-nvim-palette` (an alist of `(symbol . "#hex")`) and `kanagawa-dragon-nvim-color` (lookup fn that errors on unknown names).
- Loading this file does NOT enable the theme. It is `(require)`d by the theme file and is also intended for other consumers (statuslines, sibling ports) that want the exact hex values without reimplementing them.
- Holds `kanagawa-dragon-nvim-version`, which a test asserts equals the trimmed contents of `VERSION`. Bumping a release means updating **both** in the same commit; the same string also appears in the file headers of both `.el` files. Four places, one number.
- Hosts the opt-in `kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed` helper (see "LSP modifier bleed" below).

### `kanagawa-dragon-nvim-theme.el` — the deftheme, every face mapping

Single `(let* ...)` that pulls palette entries into short locals (`bg`, `fg`, `s-string`, `s-keyword`, `s-fun`, `s-type`, `s-ident`, `s-param`, `s-operator`, `s-punct`, `d-error`, `vcs-add`, etc.), then a long `custom-theme-set-faces` form. Doom UI faces (`doom-modeline-*`, `solaire-*`, `doom-dashboard-*`) are mapped explicitly so the theme is portable to vanilla Emacs (they no-op if those packages aren't loaded). ANSI / term colors mirror the upstream `extras/alacritty/kanagawa_dragon.toml` mapping verbatim.

### `spec.md` is the contract

Two tables (Dragon-specific palette, shared Wave-origin palette) with hex values that must match upstream byte-for-byte. The face mapping table cites the nvim semantic role (`syn.fun`, `ui.bg_visual`, `diag.warning`, etc.) for every face. If spec and code disagree, the spec is authoritative; fix the code. Palette symbol names match upstream casing (`dragonBlack3`, `dragonGreen2`, `waveBlue1`) so the spec can be cross-referenced mechanically against `kanagawa.nvim/lua/kanagawa/colors.lua`.

### Tests

- `tests/test-palette.el` — byte-for-byte palette match against an in-test copy of upstream's `colors.lua`, no stray entries, lookup helper behaviour, `VERSION` ↔ constant sync.
- `tests/test-faces.el` — spot-checks the load-bearing faces (the Java treesit ones that motivated the project) plus regression coverage for the LSP semhl variable/modifier fixes. Reads from the theme's `theme-settings` property rather than calling `face-attribute`, because in `emacs -Q --batch` many external faces (`solaire-*`, `doom-modeline-*`, `org-*`, `ansi-color-*`) aren't defined yet; the test verifies the *theme* sets the right spec, not whether the face has been realized.
- `tests/sample.{java,py,el}` — visual eyeball buffers. The acceptance check is `sample.java` opened in Doom with `treesit-font-lock-level 4`, compared against the same file in nvim with `:colorscheme kanagawa-dragon`. Same hue, same role for keywords / types / strings / function calls / operators / parameters.

## LSP modifier bleed (load-bearing context)

`lsp-mode` maps several semantic-token *modifiers* (`declaration`, `readonly`, `abstract`, `async`, `modification`, `documentation`) to *colored* type faces in `lsp-semantic-token-modifier-faces` (`lsp-face-semhl-interface`, `lsp-face-semhl-constant`, etc.). `add-face-text-property` prepends modifier faces, and first-wins composition means the modifier's colour overrides the base token colour. In Java, every declared field / method / local loses its base colour the moment jdtls attaches; whole declaration lines collapse to a single tint.

The opt-in helper `kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed` repoints the six bleeding modifiers at an empty `kanagawa-dragon-nvim-lsp-modifier-noop` face, so the modifier signal is preserved but no longer paints a colour. The five non-bleeding modifiers (`definition`, `implementation`, `defaultLibrary`, `static`, `deprecated`) are left alone. Recommended call site is `(with-eval-after-load 'lsp-semantic-tokens ...)`. The helper is idempotent and signals a `user-error` if `lsp-semantic-token-modifier-faces` isn't bound.

This is also why the LSP semhl variable/property/member faces all route to `s-ident` (`dragonYellow`): the LSP overlay must agree with the tree-sitter pass for identifier-shaped tokens, or the buffer visibly shifts when the server attaches.

## How this fits into Brandon's setup

Wired into Doom via a local-repo `package!` recipe in `~/.config/doom/packages.el` pointing at `~/.gitrepos/kanagawa-dragon-nvim-emacs`. After source edits, reload with `doom sync` (only needed if `packages.el` changes) or `SPC h r r` for face/code-only changes. The theme is the active `doom-theme`, so a broken byte-compile or face mapping is immediately visible.

## Adding palette entries or face mappings

1. Add the hex to `kanagawa-dragon-nvim-palette` AND to the matching upstream table in `tests/test-palette.el` (`kdn-test--upstream-dragon-palette` or `kdn-test--upstream-shared-palette`) AND to `spec.md`. All three must agree; the `no-stray-entries` test enforces it.
2. For a new face mapping, add the row to the spec table first (with its nvim origin), then to `kanagawa-dragon-nvim-theme.el`, then a spot-check in `tests/test-faces.el` if it's load-bearing.
3. Run `make compile` (warnings are errors) and `make test`.
