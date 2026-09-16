# kanagawa-dragon-nvim-emacs

Faithful Emacs ports of the **Dragon** and **Wave** variants of
[`kanagawa.nvim`][upstream] by [rebelot][upstream]. Built so that a Java
buffer in Doom Emacs and the same buffer in nvim look like the same
theme, not "two themes that happen to share a name."

> Independent project. Not affiliated with `kanagawa.nvim`. Distributed
> under MIT, matching upstream.

[upstream]: https://github.com/rebelot/kanagawa.nvim

## Why this exists

The existing `kanagawa-themes` Emacs package ships a Dragon palette
that's bit-for-bit correct, but doesn't map the **Emacs 29+ tree-sitter
font-lock faces** that modern modes use at `treesit-font-lock-level 4`.
The result, in Doom Emacs with `(java-mode . java-ts-mode)` remapping,
is a Java buffer where keywords, type names, function calls, operators,
and parameters all collapse to the default foreground, losing nearly
all of Dragon's semantic distinction.

This theme maps every face the spec lists, including the new treesit
buckets, so modern code modes look the way they do in nvim. Both variants
install together: `kanagawa-dragon-nvim` (Dragon) and `kanagawa-wave-nvim`
(Wave).

## Install

### Doom Emacs

In `~/.config/doom/packages.el`:

```elisp
(package! kanagawa-dragon-nvim
  :recipe (:host github :repo "VirInvictus/kanagawa-dragon-nvim-emacs"
           :files ("*.el")))
```

In `~/.config/doom/config.el`:

```elisp
(setq doom-theme 'kanagawa-dragon-nvim)  ; or 'kanagawa-wave-nvim
```

Then run `doom sync && doom run`.

### Vanilla Emacs (≥ 29.1)

Clone the repo wherever you like, then point `custom-theme-load-path` at it:

```elisp
(add-to-list 'custom-theme-load-path "/path/to/kanagawa-dragon-nvim-emacs/")
(load-theme 'kanagawa-dragon-nvim t)  ; Dragon (dark)
;; or:
(load-theme 'kanagawa-wave-nvim t)    ; Wave (dark)
```

Or via straight:

```elisp
(straight-use-package
 '(kanagawa-dragon-nvim
   :type git
   :host github
   :repo "VirInvictus/kanagawa-dragon-nvim-emacs"
   :files ("*.el")))
(load-theme 'kanagawa-dragon-nvim t)  ; or kanagawa-wave-nvim
```

## Requirements

- Emacs **29.1+** (the theme depends on the tree-sitter `font-lock-*`
  faces introduced in 29).
- For the Doom UI faces to take effect, `doom-modeline` /
  `solaire-mode` / `doom-dashboard` need to be loaded, but their
  absence is harmless; the theme just no-ops those mappings.

## LSP semantic-tokens setup (optional, recommended)

`lsp-mode` ships a `lsp-semantic-token-modifier-faces` alist that maps
semantic-token modifiers like `declaration` and `readonly` to *colored*
type faces (`lsp-face-semhl-interface`, `lsp-face-semhl-constant`, etc.).
When `add-face-text-property` composes the modifier face on top of the
base token face, the modifier face is prepended and its colour wins.
For Java (and any LSP server that emits `declaration`) every declared
field, method, and local loses its base colour the moment the server
attaches; whole declaration lines collapse to a single tint.

The theme ships a helper to repoint the bleeding modifiers at an empty
face. The modifier signal is preserved, it just no longer paints a
colour. Add this once to your config:

```elisp
(with-eval-after-load 'lsp-semantic-tokens
  (kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed))
```

That's it. The five non-bleeding modifiers (`definition`,
`implementation`, `defaultLibrary`, `static`, `deprecated`) need no
helper call: both themes pin their dedicated modifier faces
(`lsp-face-semhl-definition` and friends) to inherit `unspecified`, so
lsp-mode's mappings for them carry no colour (deprecated deliberately
keeps a strike-through). The six above map to token-type faces that
must keep their theme colours for their primary roles, so the variable
itself is what gets repointed. The full list of touched modifiers
lives in `kanagawa-dragon-nvim-lsp-bleeding-modifiers`. A
family-neutral alias, `kanagawa-nvim-neutralize-lsp-modifier-bleed`,
names the same function for Wave-only configs.

## Acceptance check

The reference comparison is `tests/sample.java` opened in Doom with
`treesit-font-lock-level 4`, against the same file in nvim with
`:colorscheme kanagawa-dragon` (or `:colorscheme kanagawa-wave` against
`kanagawa-wave-nvim`). Strings, keywords, type names,
function calls, parameters, and operators should all pick out
distinctly: same hue, same role.

## Testing

```sh
make test       # ERT: palette integrity + representative face checks
make compile    # byte-compile with -Werror
```

Tests run under `emacs -Q --batch`, so they don't touch your config.

## MELPA (pending)

The theme is MELPA-shaped but not yet submitted; the repo stays
private until that flip is decided. Preparation done as of v0.2.1:
`package-lint` is clean except one deliberate exception (the
family-neutral `kanagawa-nvim-neutralize-lsp-modifier-bleed` alias,
which MELPA's package-prefix rule would drop at submission time), and
the recipe is drafted:

```elisp
(kanagawa-dragon-nvim
 :repo "VirInvictus/kanagawa-dragon-nvim-emacs"
 :fetcher github
 :files ("*.el"))
```

## Layout

```
kanagawa-dragon-nvim.el         Palette helper (alist + lookup fn)
kanagawa-dragon-nvim-theme.el   The Dragon deftheme: every face mapping
kanagawa-wave-nvim-theme.el     The Wave deftheme: same face set, Wave values
spec.md                         Authoritative palette + face contract
roadmap.md                      Phased build, ticked when shipped
patchnotes.md                   Release notes (newest at top)
VERSION                         Single source of truth for the version
Makefile                        make test / make compile / make clean
.github/workflows/ci.yml        CI: byte-compile + theme load + tests
CLAUDE.md                       Guidance for coding agents (AGENTS.md symlinks to it)
tests/
  test-palette.el               Palette ↔ upstream byte-for-byte
  test-faces.el                 Critical face attributes resolve correctly
  sample.{java,py,el}           Visual eyeball buffers
```

## What's NOT in v0.2

- A Lotus (light) variant. Dragon and Wave are both dark; Lotus is the
  remaining upstream variant, planned for v0.3.
- Light/dark auto-detection. It will load Wave or Dragon from
  `frame-background-mode`; Wave's landing in v0.2.0 unblocked it, and
  it is the next v0.3 item.
- A tab look-parity pass against nvim's `bufferline.nvim`. The
  `centaur-tabs` / `tab-bar` / `tab-line` faces are mapped; judging
  them side-by-side against nvim is still open.
- A `doom-themes` macro dependency. Still a vanilla `deftheme`; Doom
  faces are mapped explicitly so the theme is portable to vanilla Emacs.

See [`roadmap.md`](roadmap.md) for what's planned next.

## License

MIT. Palette values originate from `kanagawa.nvim` (also MIT) by
rebelot; see [`LICENSE`](LICENSE) for the credit notice.

## Support

If this theme's useful to you and you'd like to chip in:

- liberapay · [liberapay.com/bdkl](https://liberapay.com/bdkl/)
- bitcoin
  ```
  bc1qkge6zr45tzqfwfmvma2ylumt6mg7wlwmhr05yv
  ```
