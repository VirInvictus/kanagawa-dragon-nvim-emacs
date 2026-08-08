# roadmap.md — kanagawa-dragon-nvim-emacs

Tick boxes when shipped. Each phase is independently usable.

## Repo hygiene (workspace sweep, 2026-06-09; do this first)

- [x] **Make the initial commit.** The repository has zero commits;
      everything (theme, Makefile, tests, README, LICENSE, spec,
      roadmap) has been staged since roughly 14 May, with further
      modifications layered on top. One careless reset and
      three-plus weeks of work has no history to recover from.
      This is the single most important action in this repo.
- [x] Track the untracked `CLAUDE.md`, and decide whether the two
      PNG screenshots belong in-repo or elsewhere. Decided in-repo:
      they are the before/after evidence the README's "Why this
      exists" argues in prose, and the acceptance reference `spec.md`
      cites. Now `assets/doom-emacs-before.png` and
      `assets/nvim-reference.png`.

## v0.1.0 — first faithful render

- [x] **Phase 0 — Scaffold.** Repo, license, README, spec, this file,
      patchnotes, logo, .gitignore.
- [x] **Phase 1 — Palette.** All Dragon hex values named per upstream;
      ERT cross-check against `kanagawa.nvim/lua/kanagawa/colors.lua`.
- [x] **Phase 2 — Core faces.** `default`, `cursor`, `region`, `hl-line`,
      `fringe`, `line-number(-current)`, borders, `match`, `link`,
      `error`/`warning`/`success`.
- [x] **Phase 3 — font-lock.** Classic font-lock faces.
- [x] **Phase 4 — Treesit.** Emacs 29+ `font-lock-*-call-face`,
      `*-use-face`, `operator-face`, `number-face`, `property-*-face`,
      `bracket/delimiter/punctuation/misc-punctuation`,
      `escape-face`. **This phase is what fixes Java/Python/Rust at
      `treesit-font-lock-level 4`.**
- [x] **Phase 5 — Doom UI.** `doom-modeline-*`, `doom-dashboard-*`,
      `solaire-mode`, `vc-gutter`, `tab-line`, `tab-bar`.
- [x] **Phase 6 — Org / org-modern.** Headings, blocks, todos, dates,
      modern bullets/tags.
- [x] **Phase 7 — Completion stack.** `vertico`, `corfu`, `orderless`,
      `which-key`, posframes, `marginalia`.
- [x] **Phase 8 — Polish.** `magit`, `diff-hl`, `lsp`, `flycheck`,
      `evil-ex`, ANSI/term colors (port `alacritty_kanagawa_dragon.toml`
      verbatim).
- [x] **Tests.** `tests/test-palette.el` (palette integrity),
      `tests/test-faces.el` (representative face attribute checks),
      `tests/sample.{java,py,el}` for visual acceptance.

## v0.2 — sharpen

- [ ] Light/dark detection: load Wave or Dragon based on
      `frame-background-mode`.
- [ ] Tabs: `centaur-tabs` and Emacs 28 `tab-bar` parity with nvim's
      `bufferline.nvim` look.
- [x] LSP semantic-tokens face overrides scoped narrowly so they
      don't fight font-lock.
- [x] `tests/test-faces.el` coverage extension to ≥80 faces *(shipped v0.1.3,
  2026-08-08: 182 unique faces asserted across 24 tests, sweeping the
  previously-untested families — the full font-lock and tree-sitter-hl
  namespaces, the whole lsp-semhl token family, org beyond level 4, the
  doom-modeline set, diff/vcs winter-and-autumn split, magit, the completion
  stack, the full rainbow-delimiters ladder, dired, bright ANSI/term/vterm,
  the core-UI remainder, and the flycheck/flymake fringes; every expectation
  read off the theme's binding table so drift fails by name)*.
- [ ] CI (GitHub Actions) running `make test` on Emacs 29 + 30.

## v0.3 — sibling variants

- [ ] Wave variant (`kanagawa-wave-nvim-theme.el`) sharing the palette
      helper.
- [ ] Lotus variant (light) — full second pass on every face that
      hardcoded a Dragon-specific bg.

## Out of scope (won't do)

- Doom-themes-style theme with `def-doom-theme` — keeping vanilla so the
  theme works in plain Emacs.
- Auto-screenshot regression harness — too brittle, eyeballing wins.
