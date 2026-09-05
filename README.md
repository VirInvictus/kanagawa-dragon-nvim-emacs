# kanagawa-dragon-nvim-emacs

A faithful Emacs port of the **Dragon** variant of [`kanagawa.nvim`][upstream]
by [rebelot][upstream]. Built so that a Java buffer in Doom Emacs and the
same buffer in nvim look like the same theme — not "two themes that happen
to share a name."

> Independent project. Not affiliated with `kanagawa.nvim`. Distributed
> under MIT, matching upstream.

[upstream]: https://github.com/rebelot/kanagawa.nvim

## Why this exists

The existing `kanagawa-themes` Emacs package ships a Dragon palette
that's bit-for-bit correct, but doesn't map the **Emacs 29+ tree-sitter
font-lock faces** that modern modes use at `treesit-font-lock-level 4`.
The result, in Doom Emacs with `(java-mode . java-ts-mode)` remapping,
is a Java buffer where keywords, type names, function calls, operators,
and parameters all collapse to the default foreground — losing nearly
all of Dragon's semantic distinction.

This theme maps every face the spec lists, including the new treesit
buckets, so modern code modes look the way they do in nvim.

## Install

### Doom Emacs

In `~/.config/doom/packages.el`:

```elisp
(package! kanagawa-dragon-nvim
  :recipe (:local-repo "~/.gitrepos/kanagawa-dragon-nvim-emacs"
           :files ("*.el")))
```

In `~/.config/doom/config.el`:

```elisp
(setq doom-theme 'kanagawa-dragon-nvim)
```

Then run `doom sync && doom run`.

### Vanilla Emacs (≥ 29.1)

Put the repo on `custom-theme-load-path`, then:

```elisp
(add-to-list 'custom-theme-load-path "~/.gitrepos/kanagawa-dragon-nvim-emacs/")
(load-theme 'kanagawa-dragon-nvim t)
```

Or via straight:

```elisp
(straight-use-package
 '(kanagawa-dragon-nvim
   :type git
   :host github
   :repo "VirInvictus/kanagawa-dragon-nvim-emacs"
   :files ("*.el")))
(load-theme 'kanagawa-dragon-nvim t)
```

## Requirements

- Emacs **29.1+** (the theme depends on the tree-sitter `font-lock-*`
  faces introduced in 29).
- For the Doom UI faces to take effect, `doom-modeline` /
  `solaire-mode` / `doom-dashboard` need to be loaded — but their
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
`implementation`, `defaultLibrary`, `static`, `deprecated`) are left
alone because their default mappings target dedicated modifier-only
faces with no inherent colour. The full list of touched modifiers
lives in `kanagawa-dragon-nvim-lsp-bleeding-modifiers`.

## Acceptance check

The reference comparison is `tests/sample.java` opened in Doom with
`treesit-font-lock-level 4`, against the same file in nvim with
`:colorscheme kanagawa-dragon`. Strings, keywords, type names,
function calls, parameters, and operators should all pick out
distinctly — same hue, same role.

## Testing

```sh
make test       # ERT: palette integrity + representative face checks
make compile    # byte-compile with -Werror
```

Tests run under `emacs -Q --batch`, so they don't touch your config.

## Layout

```
kanagawa-dragon-nvim.el         Palette helper (alist + lookup fn)
kanagawa-dragon-nvim-theme.el   The deftheme — every face mapping
spec.md                         Authoritative palette + face contract
roadmap.md                      Phased build, ticked when shipped
patchnotes.md                   Release notes (newest at top)
tests/
  test-palette.el               Palette ↔ upstream byte-for-byte
  test-faces.el                 Critical face attributes resolve correctly
  sample.{java,py,el}           Visual eyeball buffers
```

## What's NOT in v0.1

- Wave or Lotus variants. Dragon-only on first release; the palette
  helper is structured so siblings can be added later without touching
  shipped code.
- A light-mode toggle.
- A `doom-themes` macro dependency. This is a vanilla `deftheme`; Doom
  faces are mapped explicitly so the theme is portable to vanilla Emacs.

See [`roadmap.md`](roadmap.md) for what's planned next.

## License

MIT. Palette values originate from `kanagawa.nvim` (also MIT) by
rebelot — see [`LICENSE`](LICENSE) for the credit notice.

## Support

If this theme's useful to you and you'd like to chip in:

- liberapay · [liberapay.com/bdkl](https://liberapay.com/bdkl/)
- bitcoin
  ```
  bc1qkge6zr45tzqfwfmvma2ylumt6mg7wlwmhr05yv
  ```
