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
- [x] **Hygiene (recorded 2026-09-13, not fixed):** CI's
      `purcell/setup-emacs@master` is an unpinned floating ref; pin it
      to a version tag or SHA the next time the workflow is touched.
      *(fixed 2026-09-15: SHA-pinned at v8.0, checkout bumped to
      v7.0.1 SHA-pinned, in the same workflow touch as the snapshot
      canary fix.)*

### Final audit 2026-09-13 (THE FINAL AUDIT: NEW findings, one line each; full detail in audit-final/kanagawa-dragon-nvim-emacs/FINAL-REPORT.md)
- [x] MED — The snapshot CI leg has been PERMANENTLY RED and invisible since 2026-08-09: continue-on-error masks the job failure (kanagawa-dragon-nvim.el:135 defface missing its containing group + obsolete when-let at :176 — both tiny fixes), so the Emacs-31 canary provides zero signal. Restore it; pin setup-emacs@v8.0 and bump checkout in the same workflow touch. *(fixed 2026-09-15: defgroup added + :group on the face, when-let*; continue-on-error dropped; SHA-pins; permissions; v* tag trigger; Emacs 30.2 job; make load/load-wave. First run on the fixed workflow: snapshot green. v0.2.1.)*
- [x] MED — Both themes miss the eight vterm-color-bright-* faces (bright SGR renders unthemed); the values exist as the ansi-bright-* bindings. Add per theme. *(shipped 2026-09-15, v0.2.1: 8 rows per theme from the bright bindings = upstream term[9..16]; spec records the term[1..18] breakdown; ANSI tests assert all eight brights per variant.)*
- [x] MED — The core contract (Dragon face set == Wave face set) is enforced by nothing: add the cross-theme equality ERT (the helper exists; verified identical today; generalizes to Lotus). *(shipped 2026-09-15, v0.2.1: kdn-faces/dragon-and-wave-face-sets-identical; now guards 560 = 560.)*
- [x] MED — A typo'd palette symbol in a theme row silently resolves to nil (the inline lookup has no failure path; the exported erroring helper exists). Route through it or add a static membership test. *(fixed 2026-09-15, v0.2.1: both themes route through the erroring kanagawa-dragon-nvim-color; verified a deliberate typo errors at load.)*
- [x] MED — Comment truth: the "shared" palette grouping claims Dragon usage that isn't true (fujiWhite/fujiGray/waveAqua1 are Wave-only); the flycheck-posframe comment describes the wrong UI surface; the modifier-bleed helper docstring's rationale is wrong (four of five modifiers DO inherit color; they don't bleed because the themes unify them to unspecified — the themes' own comments state that correctly). *(fixed 2026-09-15, v0.2.1: palette comment + spec heading + test docstring state the real membership; posframe comment rewritten in both files; rationale corrected in the docstring, README, and CLAUDE.md; theme modifier comment cross-references the helper and explains the deprecated exception.)*
- [x] LOW — The solaire claim is false in Dragon: spec + test name say "darker", #1D1C19 is LIGHTER than the default (Dragon brightens real buffers; Wave darkens — siblings in opposite directions). Fix the spec parenthetical + test name now; the Dragon value change (dragonBlack1 = upstream bg_dim) is Brandon's visual call (live in Doom). *(both halves executed 2026-09-15, v0.2.1: claim fixed and test renamed to kdn-faces/solaire-bg-distinct-from-default; Brandon chose the dragonBlack1 value in the blitz gate, so Dragon and Wave now darken alike.)*
- [x] LOW — Four lsp-face-semhl rows per theme target nonexistent lsp-mode faces; inverse gap: decorator/event/label defface'd but unmapped; the 483-row table duplicated verbatim between theme files (shared-emitter refactor option, Brandon's call — counter to the shipped byte-identical choice); .elc stale-shadow hazard informational (make clean or delete at stage close); LICENSE attribution widen to "Dragon and Wave"; .claude relic + .gitignore gap; spec machine path genericize; 3 README em-dashes; make clean *.eln; version-header sync test; Rust sample buffer; Wave screenshot. *(executed 2026-09-15, v0.2.1, with the four Brandon gate calls: the dead rows annotated as harmless pins (typeparameter/enummember/declaration/readonly; default-library verified LIVE, not in the set); decorator/event/label stay unmapped, recorded optional; shared-emitter refactor DECLINED this blitz per Brandon, the equality test keeps it cheap later; .elc cleaned at stage close; LICENSE widened; .claude deleted + gitignored; spec path genericized; em-dashes recast; make clean takes *.eln; header-sync test shipped; Rust sample shipped; Wave screenshot deferred as eyes-time reopen.)*
- [x] Feature candidates logged (FINAL-REPORT L4, ranked): the equality test; the integration face pass (avy/consult/embark/transient/ediff/smerge/hl-todo — rendered daily in default colors); light/dark detection (unblocked by Wave); the Emacs 30 CI job + setup-emacs pin; the header-sync test; MELPA (flip-gated; pre-work: package-lint + the neutral helper name before any freeze); Lotus (the recipe is proven); tabs parity (eyes-time); Rust sample; Wave screenshot. Empty: terminal variants (recorded non-goal); themes beyond Lotus. *(dispositions 2026-09-15: equality test, Emacs 30 job, header-sync test, integration pass, and Rust sample shipped in v0.2.1 (hl-todo was already mapped; Brandon's config themes the keywords himself); light/dark detection stays a v0.3 box until Lotus gives "light" a real answer; MELPA prep done without the flip (lint clean but one documented alias exception, recipe drafted in the README, description/topics cover Wave), the flip itself stays gated; Lotus DEFERRED by Brandon with reopen; tabs parity + Wave screenshot await eyes-time, recorded as reopens.)*

**CONFIRMED-prior (final-audit verification):** the setup-emacs@master pin open and correctly recorded. SUPERSEDED (verified fixed): the line-number colour drift (dragonBlack5, pinned), the partial URL fix, the stale prose retitled, the tag lane (both tags pushed, both Releases verbatim, v0.2.0 Latest), the 483-face recount, the CLAUDE.md client line. Audit-side corrections: the sheet's "29 tests"/"both .el headers"/"zero tags" and the full-roadmap's "7 commits local" all lag the pushed tree. Brief-premise correction: the .elc files are NOT tracked (gitignored artifacts, currently in sync). Slop-reader verdict: reads human end to end; 5 sentence-level em-dashes in living prose + 23 separator-position author's-call dashes; the motto differs between README and spec ("themes that share a name" vs "theme families that share a name") — pick one.
