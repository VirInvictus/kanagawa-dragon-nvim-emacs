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

- [~] Light/dark detection: load Wave or Dragon based on
      `frame-background-mode`. **Moved to v0.3** (2026-08-09). It cannot be built
      where it stands: it loads the Wave variant, and Wave is a v0.3 deliverable
      that does not exist in the tree at all. The alternative was pulling Wave
      forward, but that is a second full port rather than a small add: `spec.md`
      carries only the ~23 Wave hexes Dragon itself borrows, with no Wave
      background ladder and no Wave face table, so it is comparable in size to the
      original Dragon port. Detection is a two-line function once a second variant
      exists and is worth nothing before then, so it follows Wave rather than
      leading it.
- [ ] Tabs: a look-parity pass. The `centaur-tabs` and Emacs 28 `tab-bar`
      faces are already mapped (v0.1.0's Phase 5); what remains is judging
      the result against nvim's `bufferline.nvim` look, which is subjective
      and needs eyes on both.
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
- [x] CI (GitHub Actions) running `make compile` + theme load + `make test`
      *(shipped silently in the initial commit and green since; ticked
      2026-09-05 when the audit found it. The matrix is Emacs 29.1, 29.4, and
      snapshot — no Emacs 30 job, so the original "29 + 30" wording was
      never true. The owed patchnotes mention landed in the v0.2.0
      entry; CI now loads both themes.)*

## v0.3 — sibling variants

- [x] Wave variant (`kanagawa-wave-nvim-theme.el`) sharing the palette
      helper. **Blocks the light/dark detection moved down from v0.2**, so it is
      the first item of this milestone rather than one of three equals.
      *(shipped v0.2.0, 2026-09-13: spec tables first, then 14 palette
      entries cross-checked byte-for-byte against upstream colors.lua,
      then the theme file with the identical 483-face set, then the
      tests; suite 29 to 42 and CI loads both themes. Milestone
      headings here don't track release versions, so this is the
      v0.2.0 release.)*
- [ ] Light/dark detection: load Wave or Dragon from `frame-background-mode`
      (moved from v0.2; needs the Wave variant above).
- [ ] Lotus variant (light) — full second pass on every face that
      hardcoded a Dragon-specific bg.

## Out of scope (won't do)

- Doom-themes-style theme with `def-doom-theme` — keeping vanilla so the
  theme works in plain Emacs.
- Auto-screenshot regression harness — too brittle, eyeballing wins.

## New findings 2026-09-12 (six-lens full audit; detail: audit/FULL-AUDIT-2026-09-12.md, Wave 22)

- [x] **line-number colour drift:** spec's face table says dragonBlack6;
      the theme binds bg-p2 = dragonBlack5 and the test pins dragonBlack5
      - code+test agree against the spec, violating the "spec is
      authoritative" rule. One edit: correct the spec row to Black5 (or
      move the theme). *(fixed 2026-09-13: the spec row now says
      dragonBlack5; code and test were already there.)*
- [x] **The 09-05 URL fix was partial:** the Doom recipe still uses
      :local-repo with Brandon's literal home path and the vanilla example
      hardcodes it. Give Doom a proper github recipe; genericize the
      snippet. *(fixed 2026-09-13: Doom gets :host github/:repo, the
      vanilla snippet takes a generic path.)*
- [x] **Stale prose:** "What's NOT in v0.1" heading at v0.1.4 + the Wave
      deferral wording predates the v0.1.4 roadmap correction; the CI
      tick's owed patchnotes mention is still queued; Layout omits
      Makefile/VERSION/CI/AGENTS.md. *(fixed 2026-09-13: retitled to
      "What's NOT in v0.2" and rewritten against the shipped roadmap,
      Layout completed, and the CI-truth mention landed in the v0.2.0
      patchnotes entry.)*
- [x] **On the queued v0.1.4 tag lane:** pair the tag with a GitHub
      Release (populates latestRelease); the repo is PRIVATE so the
      drafted description/topics wait for a public flip; note the LICENSE
      appendix makes GitHub classify "Other" (accept or move the credit
      to the README only). *(executed 2026-09-13: v0.1.4 annotated tag cut
      at 365e56c by the verbatim procedure and pushed with its GitHub
      Release; LICENSE/credit classification recorded as accepted
      hygiene, not fixed.)*
- [ ] **Hygiene (recorded 2026-09-13, not fixed):** CI's
      `purcell/setup-emacs@master` is an unpinned floating ref; pin it
      to a version tag or SHA the next time the workflow is touched.
