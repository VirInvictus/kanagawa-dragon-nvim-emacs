;;; test-faces.el --- Face attribute checks for both themes -*- lexical-binding: t; -*-

;; Loads the themes into a batch Emacs and asserts that the face specs
;; recorded under each theme carry the expected attributes from the
;; spec: spot-checks for the load-bearing faces (the Java treesit set
;; whose collapse motivated the project), a Wave set mirroring the
;; load-bearing Dragon checks, and structural invariants over both
;; themes (no face specified twice, every hex a palette member, and
;; Dragon's face set identical to Wave's).
;;
;; Implementation note: we read from `theme-settings' directly rather
;; than calling `face-attribute', because in `emacs -Q --batch' many
;; external faces (solaire, doom-modeline, org, ansi-color) aren't
;; defined yet.  We're testing that the *theme* sets the right thing,
;; not whether the face has been realized.

;;; Code:

(require 'ert)
(require 'kanagawa-dragon-nvim)

;; Declared as special so `let' bindings below give dynamic scope, which
;; is what the helper expects via `boundp'. Without this, lexical-binding
;; mode would let-bind it lexically and the helper would correctly refuse
;; to run.
(defvar lsp-semantic-token-modifier-faces)

;; Capture the repo root at load time — `load-file-name' is only bound
;; while the file is being loaded, not when ERT runs the tests later.
(defconst kdn-test--root
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name))))
  "Absolute path to the repo root, captured at load time.")

(defun kdn-test--load-theme ()
  "Load the Dragon theme without prompting in a batch session."
  (add-to-list 'custom-theme-load-path kdn-test--root)
  (load-theme 'kanagawa-dragon-nvim :no-confirm))

(defun kdn-test--load-wave-theme ()
  "Load the Wave theme without prompting in a batch session."
  (add-to-list 'custom-theme-load-path kdn-test--root)
  (load-theme 'kanagawa-wave-nvim :no-confirm))

(defun kdn-test--face-spec-attr (theme face attr)
  "Pull ATTR (e.g. `:foreground') out of FACE's spec under THEME.
Reads from `theme-settings' so external faces that haven't been
`defface'd yet can still be verified."
  (let* ((settings (get theme 'theme-settings))
         (entry (seq-find (lambda (s)
                            (and (eq (nth 0 s) 'theme-face)
                                 (eq (nth 1 s) face)))
                          settings)))
    (unless entry
      (error "kdn-test: theme %S has no spec for face %S" theme face))
    ;; entry shape: (theme-face FACE THEME SPEC)
    ;; SPEC shape: ((DISPLAY PLIST) ...) — we want the first plist's ATTR.
    (let* ((spec (nth 3 entry))
           (plist (cadr (car spec))))
      (plist-get plist attr))))

(defmacro kdn-test--should-fg (face palette-name)
  "Assert FACE's spec :foreground equals palette entry PALETTE-NAME (Dragon)."
  `(should (string-equal-ignore-case
            (kdn-test--face-spec-attr 'kanagawa-dragon-nvim ,face :foreground)
            (kanagawa-dragon-nvim-color ,palette-name))))

(defmacro kdn-test--should-bg (face palette-name)
  "Assert FACE's spec :background equals palette entry PALETTE-NAME (Dragon)."
  `(should (string-equal-ignore-case
            (kdn-test--face-spec-attr 'kanagawa-dragon-nvim ,face :background)
            (kanagawa-dragon-nvim-color ,palette-name))))

(defmacro kdn-test--wave-should-fg (face palette-name)
  "Assert FACE's spec :foreground under the Wave theme equals PALETTE-NAME."
  `(should (string-equal-ignore-case
            (kdn-test--face-spec-attr 'kanagawa-wave-nvim ,face :foreground)
            (kanagawa-dragon-nvim-color ,palette-name))))

(defmacro kdn-test--wave-should-bg (face palette-name)
  "Assert FACE's spec :background under the Wave theme equals PALETTE-NAME."
  `(should (string-equal-ignore-case
            (kdn-test--face-spec-attr 'kanagawa-wave-nvim ,face :background)
            (kanagawa-dragon-nvim-color ,palette-name))))

(ert-deftest kdn-faces/core-default ()
  (kdn-test--load-theme)
  (kdn-test--should-bg 'default 'dragonBlack3)
  (kdn-test--should-fg 'default 'dragonWhite))

(ert-deftest kdn-faces/core-region-and-hl-line ()
  (kdn-test--load-theme)
  (kdn-test--should-bg 'region 'waveBlue1)
  (kdn-test--should-bg 'hl-line 'dragonBlack4))

(ert-deftest kdn-faces/syntax-strings-keywords-types ()
  "The motivating bug — Java strings/keywords/types must NOT
collapse to default fg."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'font-lock-string-face   'dragonGreen2)
  (kdn-test--should-fg 'font-lock-keyword-face  'dragonViolet)
  (kdn-test--should-fg 'font-lock-type-face     'dragonAqua)
  (kdn-test--should-fg 'font-lock-comment-face  'dragonAsh))

(ert-deftest kdn-faces/treesit-additions-mapped ()
  "Without these the treesit-level-4 highlighting goes monochrome."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'font-lock-function-call-face 'dragonBlue2)
  (kdn-test--should-fg 'font-lock-operator-face      'dragonRed)
  (kdn-test--should-fg 'font-lock-number-face        'dragonPink)
  (kdn-test--should-fg 'font-lock-property-use-face  'dragonYellow)
  (kdn-test--should-fg 'font-lock-bracket-face       'dragonGray2)
  (kdn-test--should-fg 'font-lock-delimiter-face     'dragonGray2)
  (kdn-test--should-fg 'font-lock-punctuation-face   'dragonGray2))

(ert-deftest kdn-faces/diagnostics ()
  (kdn-test--load-theme)
  (kdn-test--should-fg 'error   'samuraiRed)
  (kdn-test--should-fg 'warning 'roninYellow)
  (kdn-test--should-fg 'success 'springGreen))

(ert-deftest kdn-faces/lsp-semhl-variable-not-flattened ()
  "Regression: when LSP semantic tokens overlay an already-highlighted
buffer, `lsp-face-semhl-variable' must paint variables with the same
palette colour the font-lock pass would (`s-ident' = `dragonYellow').
Earlier this routed to `fg' (`dragonWhite'), which made variables
disappear into the default foreground the moment jdtls attached."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'lsp-face-semhl-variable 'dragonYellow)
  ;; Family sanity check — property / member already align with variable;
  ;; if any of these three drifts apart, the LSP overlay will visibly
  ;; disagree with the tree-sitter pass for identifier-shaped tokens.
  (kdn-test--should-fg 'lsp-face-semhl-property 'dragonYellow)
  (kdn-test--should-fg 'lsp-face-semhl-member   'dragonYellow))

(ert-deftest kdn-helpers/lsp-modifier-bleed-rebinds-bleeders ()
  "`kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed' must repoint
every entry listed in `kanagawa-dragon-nvim-lsp-bleeding-modifiers'
at the no-op face, and must leave non-bleeding modifiers alone.

This is the fix for the `int width;' / `void calculateArea()' collapse
after jdtls attaches — lsp-mode reuses colored type faces as modifier
markers, and the modifier's colour wins the face composition."
  (require 'kanagawa-dragon-nvim)
  (should (functionp 'kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed))
  (let ((lsp-semantic-token-modifier-faces
         '(("declaration"  . lsp-face-semhl-interface)
           ("readonly"     . lsp-face-semhl-constant)
           ("abstract"     . lsp-face-semhl-keyword)
           ("async"        . lsp-face-semhl-macro)
           ("modification" . lsp-face-semhl-operator)
           ("documentation". lsp-face-semhl-comment)
           ("definition"   . lsp-face-semhl-definition)
           ("static"       . lsp-face-semhl-static))))
    (kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed)
    (dolist (mod kanagawa-dragon-nvim-lsp-bleeding-modifiers)
      (should (eq (cdr (assoc mod lsp-semantic-token-modifier-faces))
                  'kanagawa-dragon-nvim-lsp-modifier-noop)))
    ;; Non-bleeding modifiers must be untouched.
    (should (eq (cdr (assoc "definition" lsp-semantic-token-modifier-faces))
                'lsp-face-semhl-definition))
    (should (eq (cdr (assoc "static" lsp-semantic-token-modifier-faces))
                'lsp-face-semhl-static))))

(ert-deftest kdn-helpers/neutral-alias-resolves-to-helper ()
  "The family-neutral name is a live alias of the prefixed helper, so
Wave-only users can call either spelling."
  (require 'kanagawa-dragon-nvim)
  (should (eq (symbol-function 'kanagawa-nvim-neutralize-lsp-modifier-bleed)
              'kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed)))


(ert-deftest kdn-faces/org-headings-step-by-hue ()
  (kdn-test--load-theme)
  (kdn-test--should-fg 'org-level-1 'dragonViolet)
  (kdn-test--should-fg 'org-level-2 'dragonBlue2)
  (kdn-test--should-fg 'org-level-3 'dragonAqua)
  (kdn-test--should-fg 'org-level-4 'dragonGreen2))

(ert-deftest kdn-faces/doom-modeline-when-defined ()
  (kdn-test--load-theme)
  (kdn-test--should-fg 'doom-modeline-buffer-file 'dragonAqua)
  (kdn-test--should-fg 'doom-modeline-info        'dragonGreen2))

(ert-deftest kdn-faces/solaire-bg-distinct-from-default ()
  "Solaire's bg sits one step off the default, which is what makes
Doom buffers feel right: since the 2026-09-15 decision both variants
darken real buffers, Dragon to bg_dim (dragonBlack1) and Wave one
step (sumiInk2 over sumiInk3). Guard against accidentally using `bg'
itself."
  (kdn-test--load-theme)
  (kdn-test--should-bg 'solaire-default-face 'dragonBlack1)
  (kdn-test--should-bg 'default              'dragonBlack3))

(ert-deftest kdn-faces/ansi-dragon-mapping ()
  (kdn-test--load-theme)
  (kdn-test--should-fg 'ansi-color-red    'dragonRed)
  (kdn-test--should-fg 'ansi-color-green  'dragonGreen2)
  (kdn-test--should-fg 'ansi-color-blue   'dragonBlue2)
  (kdn-test--should-fg 'ansi-color-yellow 'dragonYellow)
  (kdn-test--should-fg 'ansi-color-cyan   'dragonAqua)
  (kdn-test--should-fg 'ansi-color-magenta 'dragonPink))

;; ------------------------------------------------------------------
;; v0.2 coverage extension (roadmap: "coverage extension to ≥80
;; faces").  The groups below sweep the remaining defined-but-untested
;; families.  Every expectation is read off the theme's let*-binding
;; table (e.g. `s-fun' = dragonBlue2, `s-ident' = dragonYellow), so a
;; drifted binding or a typo'd face entry fails by name.
;; Inherit-only faces (e.g. tree-sitter-hl-face:comment) are skipped:
;; the helper reads concrete :foreground/:background plist entries.
;; ------------------------------------------------------------------

(ert-deftest kdn-faces/font-lock-remainder ()
  "The font-lock faces the original spot-check left uncovered."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'font-lock-builtin-face        'dragonViolet)
  (kdn-test--should-fg 'font-lock-constant-face       'dragonOrange)
  (kdn-test--should-fg 'font-lock-function-name-face  'dragonBlue2)
  (kdn-test--should-fg 'font-lock-variable-name-face  'dragonYellow)
  (kdn-test--should-fg 'font-lock-variable-use-face   'dragonGray)
  (kdn-test--should-fg 'font-lock-property-name-face  'dragonYellow)
  (kdn-test--should-fg 'font-lock-preprocessor-face   'dragonRed)
  (kdn-test--should-fg 'font-lock-regexp-face         'dragonRed)
  (kdn-test--should-fg 'font-lock-escape-face         'dragonRed)
  (kdn-test--should-fg 'font-lock-negation-char-face  'dragonRed)
  (kdn-test--should-fg 'font-lock-doc-face            'dragonAsh)
  (kdn-test--should-fg 'font-lock-doc-markup-face     'dragonGray3)
  (kdn-test--should-fg 'font-lock-misc-punctuation-face 'dragonGray2)
  (kdn-test--should-fg 'font-lock-warning-face        'roninYellow))

(ert-deftest kdn-faces/tree-sitter-hl-namespace ()
  "The elisp-tree-sitter package's own face namespace must agree with
the font-lock mapping for the same semantic roles."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'tree-sitter-hl-face:constant           'dragonOrange)
  (kdn-test--should-fg 'tree-sitter-hl-face:constructor        'dragonAqua)
  (kdn-test--should-fg 'tree-sitter-hl-face:escape             'dragonRed)
  (kdn-test--should-fg 'tree-sitter-hl-face:function           'dragonBlue2)
  (kdn-test--should-fg 'tree-sitter-hl-face:function.call      'dragonBlue2)
  (kdn-test--should-fg 'tree-sitter-hl-face:function.macro     'dragonRed)
  (kdn-test--should-fg 'tree-sitter-hl-face:function.special   'dragonTeal)
  (kdn-test--should-fg 'tree-sitter-hl-face:keyword            'dragonViolet)
  (kdn-test--should-fg 'tree-sitter-hl-face:label              'dragonTeal)
  (kdn-test--should-fg 'tree-sitter-hl-face:method.call        'dragonBlue2)
  (kdn-test--should-fg 'tree-sitter-hl-face:number             'dragonPink)
  (kdn-test--should-fg 'tree-sitter-hl-face:operator           'dragonRed)
  (kdn-test--should-fg 'tree-sitter-hl-face:property           'dragonYellow)
  (kdn-test--should-fg 'tree-sitter-hl-face:punctuation.bracket 'dragonGray2)
  (kdn-test--should-fg 'tree-sitter-hl-face:string             'dragonGreen2)
  (kdn-test--should-fg 'tree-sitter-hl-face:tag                'dragonViolet)
  (kdn-test--should-fg 'tree-sitter-hl-face:type               'dragonAqua)
  (kdn-test--should-fg 'tree-sitter-hl-face:type.builtin       'dragonAqua)
  (kdn-test--should-fg 'tree-sitter-hl-face:variable           'dragonYellow)
  (kdn-test--should-fg 'tree-sitter-hl-face:variable.builtin   'dragonRed)
  (kdn-test--should-fg 'tree-sitter-hl-face:variable.parameter 'dragonGray))

(ert-deftest kdn-faces/lsp-semhl-full-family ()
  "The whole semantic-token family, not just the identifier trio: the
LSP overlay must agree with font-lock for every token type."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'lsp-face-semhl-class        'dragonAqua)
  (kdn-test--should-fg 'lsp-face-semhl-interface    'dragonAqua)
  (kdn-test--should-fg 'lsp-face-semhl-enum         'dragonAqua)
  (kdn-test--should-fg 'lsp-face-semhl-struct       'dragonAqua)
  (kdn-test--should-fg 'lsp-face-semhl-type         'dragonAqua)
  (kdn-test--should-fg 'lsp-face-semhl-namespace    'dragonAqua)
  (kdn-test--should-fg 'lsp-face-semhl-function     'dragonBlue2)
  (kdn-test--should-fg 'lsp-face-semhl-method       'dragonBlue2)
  (kdn-test--should-fg 'lsp-face-semhl-macro        'dragonRed)
  (kdn-test--should-fg 'lsp-face-semhl-keyword      'dragonViolet)
  (kdn-test--should-fg 'lsp-face-semhl-string       'dragonGreen2)
  (kdn-test--should-fg 'lsp-face-semhl-number       'dragonPink)
  (kdn-test--should-fg 'lsp-face-semhl-operator     'dragonRed)
  (kdn-test--should-fg 'lsp-face-semhl-constant     'dragonOrange)
  (kdn-test--should-fg 'lsp-face-semhl-enum-member  'dragonOrange)
  (kdn-test--should-fg 'lsp-face-semhl-parameter    'dragonGray))

(ert-deftest kdn-faces/org-remainder ()
  "Org beyond the first four heading levels: the whole ladder plus the
agenda and markup surfaces."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'org-level-5           'dragonYellow)
  (kdn-test--should-fg 'org-level-6           'dragonOrange)
  (kdn-test--should-fg 'org-level-7           'dragonPink)
  (kdn-test--should-fg 'org-level-8           'dragonRed)
  (kdn-test--should-fg 'org-document-title    'dragonViolet)
  (kdn-test--should-fg 'org-todo              'dragonOrange)
  (kdn-test--should-fg 'org-done              'dragonAsh)
  (kdn-test--should-fg 'org-date              'dragonAqua)
  (kdn-test--should-fg 'org-link              'dragonBlue2)
  (kdn-test--should-fg 'org-verbatim          'dragonGreen2)
  (kdn-test--should-fg 'org-code              'dragonBlue2)
  (kdn-test--should-bg 'org-block             'dragonBlack1)
  (kdn-test--should-fg 'org-tag               'dragonTeal)
  (kdn-test--should-fg 'org-agenda-date       'dragonAqua)
  (kdn-test--should-fg 'org-agenda-date-today 'dragonViolet)
  (kdn-test--should-fg 'org-scheduled         'dragonGreen2)
  (kdn-test--should-fg 'org-upcoming-deadline 'dragonRed))

(ert-deftest kdn-faces/doom-modeline-remainder ()
  (kdn-test--load-theme)
  (kdn-test--should-bg 'doom-modeline-bar               'dragonViolet)
  (kdn-test--should-fg 'doom-modeline-buffer-path       'dragonAqua)
  (kdn-test--should-fg 'doom-modeline-buffer-modified   'dragonOrange)
  (kdn-test--should-fg 'doom-modeline-buffer-major-mode 'dragonBlue2)
  (kdn-test--should-fg 'doom-modeline-project-dir       'dragonBlue2)
  (kdn-test--should-fg 'doom-modeline-warning           'roninYellow)
  (kdn-test--should-fg 'doom-modeline-urgent            'samuraiRed)
  (kdn-test--should-fg 'doom-modeline-lsp-success       'springGreen)
  (kdn-test--should-fg 'doom-modeline-evil-normal-state 'dragonAqua)
  (kdn-test--should-fg 'doom-modeline-evil-insert-state 'dragonGreen2)
  (kdn-test--should-fg 'doom-modeline-evil-visual-state 'dragonOrange))

(ert-deftest kdn-faces/diff-and-vcs ()
  "Diff backgrounds ride the winter* palette, gutter foregrounds the
autumn* palette — the upstream diff/vcs split."
  (kdn-test--load-theme)
  (kdn-test--should-bg 'diff-added          'winterGreen)
  (kdn-test--should-fg 'diff-added          'autumnGreen)
  (kdn-test--should-bg 'diff-removed        'winterRed)
  (kdn-test--should-fg 'diff-removed        'autumnRed)
  (kdn-test--should-bg 'diff-changed        'winterBlue)
  (kdn-test--should-fg 'diff-changed        'autumnYellow)
  (kdn-test--should-fg 'diff-hl-insert      'autumnGreen)
  (kdn-test--should-fg 'diff-hl-delete      'autumnRed)
  (kdn-test--should-fg 'git-gutter:modified 'autumnYellow))

(ert-deftest kdn-faces/magit ()
  (kdn-test--load-theme)
  (kdn-test--should-fg 'magit-section-heading 'dragonViolet)
  (kdn-test--should-fg 'magit-branch-local    'dragonAqua)
  (kdn-test--should-fg 'magit-branch-remote   'dragonGreen2)
  (kdn-test--should-fg 'magit-tag             'dragonOrange)
  (kdn-test--should-fg 'magit-hash            'dragonAsh)
  (kdn-test--should-fg 'magit-blame-name      'dragonGreen2)
  (kdn-test--should-bg 'magit-diff-added      'winterGreen)
  (kdn-test--should-fg 'magit-process-ok      'springGreen)
  (kdn-test--should-fg 'magit-log-author      'dragonBlue2))

(ert-deftest kdn-faces/completion-stack ()
  (kdn-test--load-theme)
  (kdn-test--should-bg 'vertico-current         'waveBlue1)
  (kdn-test--should-fg 'vertico-group-title     'dragonViolet)
  (kdn-test--should-bg 'corfu-default           'dragonBlack0)
  (kdn-test--should-bg 'corfu-current           'waveBlue1)
  (kdn-test--should-bg 'corfu-bar               'dragonViolet)
  (kdn-test--should-fg 'corfu-deprecated        'katanaGray)
  (kdn-test--should-fg 'orderless-match-face-0  'dragonBlue2)
  (kdn-test--should-fg 'orderless-match-face-1  'dragonGreen2)
  (kdn-test--should-fg 'orderless-match-face-2  'dragonAqua)
  (kdn-test--should-fg 'orderless-match-face-3  'dragonOrange)
  (kdn-test--should-fg 'marginalia-key          'dragonBlue2)
  (kdn-test--should-fg 'marginalia-date         'dragonAqua)
  (kdn-test--should-fg 'which-key-key-face      'dragonYellow)
  (kdn-test--should-fg 'company-tooltip-common  'dragonBlue2))

(ert-deftest kdn-faces/rainbow-delimiters-full-ladder ()
  "All nine depths cycle the palette in the documented order; a
re-ordering would be invisible to a spot check."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'rainbow-delimiters-depth-1-face 'dragonViolet)
  (kdn-test--should-fg 'rainbow-delimiters-depth-2-face 'dragonBlue2)
  (kdn-test--should-fg 'rainbow-delimiters-depth-3-face 'dragonAqua)
  (kdn-test--should-fg 'rainbow-delimiters-depth-4-face 'dragonGreen2)
  (kdn-test--should-fg 'rainbow-delimiters-depth-5-face 'dragonYellow)
  (kdn-test--should-fg 'rainbow-delimiters-depth-6-face 'dragonOrange)
  (kdn-test--should-fg 'rainbow-delimiters-depth-7-face 'dragonPink)
  (kdn-test--should-fg 'rainbow-delimiters-depth-8-face 'dragonRed)
  (kdn-test--should-fg 'rainbow-delimiters-depth-9-face 'dragonTeal)
  (kdn-test--should-fg 'rainbow-delimiters-mismatched-face 'samuraiRed))

(ert-deftest kdn-faces/dired ()
  (kdn-test--load-theme)
  (kdn-test--should-fg 'dired-directory      'dragonBlue2)
  (kdn-test--should-fg 'dired-symlink        'dragonTeal)
  (kdn-test--should-fg 'dired-broken-symlink 'samuraiRed)
  (kdn-test--should-fg 'dired-header         'dragonViolet)
  (kdn-test--should-fg 'dired-marked         'dragonOrange)
  (kdn-test--should-fg 'dired-flagged        'samuraiRed)
  (kdn-test--should-fg 'dired-ignored        'oldWhite))

(ert-deftest kdn-faces/ansi-bright-and-term ()
  "The bright ANSI row mirrors upstream's alacritty extras verbatim,
and term/vterm reuse the same mapping, including vterm's bright
faces, so bright SGR (90-97/100-107) does not render unthemed."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'ansi-color-bright-red     'waveRed)
  (kdn-test--should-fg 'ansi-color-bright-green   'dragonGreen)
  (kdn-test--should-fg 'ansi-color-bright-yellow  'carpYellow)
  (kdn-test--should-fg 'ansi-color-bright-blue    'springBlue)
  (kdn-test--should-fg 'ansi-color-bright-magenta 'springViolet1)
  (kdn-test--should-fg 'ansi-color-bright-cyan    'waveAqua2)
  (kdn-test--should-fg 'term-color-red            'dragonRed)
  (kdn-test--should-fg 'term-color-cyan           'dragonAqua)
  (kdn-test--should-fg 'vterm-color-green         'dragonGreen2)
  (kdn-test--should-fg 'vterm-color-bright-black   'dragonGray)
  (kdn-test--should-fg 'vterm-color-bright-red     'waveRed)
  (kdn-test--should-fg 'vterm-color-bright-green   'dragonGreen)
  (kdn-test--should-fg 'vterm-color-bright-yellow  'carpYellow)
  (kdn-test--should-fg 'vterm-color-bright-blue    'springBlue)
  (kdn-test--should-fg 'vterm-color-bright-magenta 'springViolet1)
  (kdn-test--should-fg 'vterm-color-bright-cyan    'waveAqua2)
  (kdn-test--should-fg 'vterm-color-bright-white   'dragonWhite))

(ert-deftest kdn-faces/core-ui-remainder ()
  (kdn-test--load-theme)
  (kdn-test--should-bg 'mode-line          'dragonBlack2)
  (kdn-test--should-bg 'mode-line-inactive 'dragonBlack1)
  (kdn-test--should-fg 'minibuffer-prompt  'dragonViolet)
  (kdn-test--should-bg 'isearch            'waveBlue2)
  (kdn-test--should-bg 'lazy-highlight     'waveBlue1)
  (kdn-test--should-bg 'show-paren-match   'dragonTeal)
  (kdn-test--should-fg 'line-number        'dragonBlack5)
  (kdn-test--should-fg 'fringe             'dragonBlack6)
  (kdn-test--should-fg 'link               'dragonBlue2)
  (kdn-test--should-fg 'shadow             'oldWhite)
  (kdn-test--should-fg 'mode-line-buffer-id 'dragonAqua))

(ert-deftest kdn-faces/flycheck-flymake-fringes ()
  (kdn-test--load-theme)
  (kdn-test--should-fg 'flycheck-fringe-error      'samuraiRed)
  (kdn-test--should-fg 'flycheck-fringe-warning    'roninYellow)
  (kdn-test--should-fg 'flycheck-fringe-info       'dragonBlue)
  (kdn-test--should-fg 'flycheck-error-list-error  'samuraiRed))

;; ------------------------------------------------------------------
;; Wave variant spot-checks (v0.2.0).  Same shape as the Dragon set:
;; expectations are read off the wave binding table in
;; kanagawa-wave-nvim-theme.el, so a drifted binding fails by name.
;; ------------------------------------------------------------------

(ert-deftest kdn-faces/wave-core-default ()
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-bg 'default 'sumiInk3)
  (kdn-test--wave-should-fg 'default 'fujiWhite)
  (kdn-test--wave-should-bg 'region 'waveBlue1)
  (kdn-test--wave-should-bg 'hl-line 'sumiInk4))

(ert-deftest kdn-faces/wave-syntax-motivating-set ()
  "The Wave answer to the motivating bug: at treesit-font-lock-level
4, strings/keywords/types/comments must hold their Wave hues."
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-fg 'font-lock-string-face  'springGreen)
  (kdn-test--wave-should-fg 'font-lock-keyword-face 'oniViolet)
  (kdn-test--wave-should-fg 'font-lock-type-face    'waveAqua2)
  (kdn-test--wave-should-fg 'font-lock-comment-face 'fujiGray))

(ert-deftest kdn-faces/wave-treesit-additions-mapped ()
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-fg 'font-lock-function-call-face 'crystalBlue)
  (kdn-test--wave-should-fg 'font-lock-operator-face      'boatYellow2)
  (kdn-test--wave-should-fg 'font-lock-number-face        'sakuraPink)
  (kdn-test--wave-should-fg 'font-lock-property-use-face  'carpYellow)
  (kdn-test--wave-should-fg 'font-lock-variable-use-face  'oniViolet2)
  (kdn-test--wave-should-fg 'font-lock-bracket-face       'springViolet2)
  (kdn-test--wave-should-fg 'font-lock-escape-face        'waveRed))

(ert-deftest kdn-faces/wave-diagnostics ()
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-fg 'error   'samuraiRed)
  (kdn-test--wave-should-fg 'warning 'roninYellow)
  (kdn-test--wave-should-fg 'success 'springGreen))

(ert-deftest kdn-faces/wave-lsp-semhl-identifier-trio ()
  "Same contract as Dragon: the LSP overlay must agree with the
tree-sitter pass for identifier-shaped tokens, here `carpYellow'."
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-fg 'lsp-face-semhl-variable 'carpYellow)
  (kdn-test--wave-should-fg 'lsp-face-semhl-property 'carpYellow)
  (kdn-test--wave-should-fg 'lsp-face-semhl-member   'carpYellow))

(ert-deftest kdn-faces/wave-line-number-derived-pin ()
  "Wave's line-number fg derives from bg-p2 (sumiInk5), the same
derivation whose spec drift the 2026-09-12 audit caught for Dragon."
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-fg 'line-number 'sumiInk5)
  (kdn-test--wave-should-fg 'fringe      'sumiInk6))

(ert-deftest kdn-faces/wave-org-headings-step-by-hue ()
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-fg 'org-level-1 'oniViolet)
  (kdn-test--wave-should-fg 'org-level-2 'crystalBlue)
  (kdn-test--wave-should-fg 'org-level-3 'waveAqua2)
  (kdn-test--wave-should-fg 'org-level-4 'springGreen)
  (kdn-test--wave-should-fg 'org-level-5 'carpYellow)
  (kdn-test--wave-should-fg 'org-level-6 'surimiOrange)
  (kdn-test--wave-should-fg 'org-level-7 'sakuraPink)
  (kdn-test--wave-should-fg 'org-level-8 'boatYellow2))

(ert-deftest kdn-faces/wave-ansi-term-mapping ()
  "Wave ANSI mirrors upstream term[1..18] from themes.lua; the
alacritty extra's #090618 black is deliberately not used (see spec)."
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-fg 'ansi-color-red     'autumnRed)
  (kdn-test--wave-should-fg 'ansi-color-green   'autumnGreen)
  (kdn-test--wave-should-fg 'ansi-color-yellow  'boatYellow2)
  (kdn-test--wave-should-fg 'ansi-color-blue    'crystalBlue)
  (kdn-test--wave-should-fg 'ansi-color-magenta 'oniViolet)
  (kdn-test--wave-should-fg 'ansi-color-cyan    'waveAqua1)
  (kdn-test--wave-should-fg 'ansi-color-bright-black 'fujiGray)
  (kdn-test--wave-should-fg 'ansi-color-bright-white 'fujiWhite)
  (kdn-test--wave-should-fg 'term-color-cyan   'waveAqua1)
  (kdn-test--wave-should-fg 'vterm-color-green 'autumnGreen)
  (kdn-test--wave-should-fg 'vterm-color-bright-black   'fujiGray)
  (kdn-test--wave-should-fg 'vterm-color-bright-red     'samuraiRed)
  (kdn-test--wave-should-fg 'vterm-color-bright-green   'springGreen)
  (kdn-test--wave-should-fg 'vterm-color-bright-yellow  'carpYellow)
  (kdn-test--wave-should-fg 'vterm-color-bright-blue    'springBlue)
  (kdn-test--wave-should-fg 'vterm-color-bright-magenta 'springViolet1)
  (kdn-test--wave-should-fg 'vterm-color-bright-cyan    'waveAqua2)
  (kdn-test--wave-should-fg 'vterm-color-bright-white   'fujiWhite))

(ert-deftest kdn-faces/wave-core-ui-completion-solaire ()
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-bg 'mode-line          'sumiInk2)
  (kdn-test--wave-should-bg 'mode-line-inactive 'sumiInk1)
  (kdn-test--wave-should-fg 'minibuffer-prompt  'oniViolet)
  (kdn-test--wave-should-bg 'isearch            'waveBlue2)
  (kdn-test--wave-should-bg 'show-paren-match   'springBlue)
  (kdn-test--wave-should-fg 'link               'crystalBlue)
  (kdn-test--wave-should-fg 'shadow             'oldWhite)
  (kdn-test--wave-should-bg 'vertico-current    'waveBlue1)
  (kdn-test--wave-should-bg 'corfu-default      'sumiInk0)
  (kdn-test--wave-should-fg 'doom-modeline-buffer-file 'waveAqua2)
  (kdn-test--wave-should-bg 'doom-modeline-bar  'oniViolet)
  (kdn-test--wave-should-bg 'solaire-default-face 'sumiInk2))

(ert-deftest kdn-faces/wave-diff-and-vcs ()
  "Wave keeps Dragon's winter*/autumn* diff and gutter split verbatim."
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-bg 'diff-added   'winterGreen)
  (kdn-test--wave-should-fg 'diff-added   'autumnGreen)
  (kdn-test--wave-should-bg 'diff-removed 'winterRed)
  (kdn-test--wave-should-fg 'diff-removed 'autumnRed)
  (kdn-test--wave-should-fg 'git-gutter:modified 'autumnYellow))

;; ------------------------------------------------------------------
;; Integration surfaces (v0.2.1): avy / consult / embark / transient /
;; ediff / smerge.  Representative rows per family; the structural
;; tests (uniqueness, palette membership, cross-theme equality) cover
;; the full set.
;; ------------------------------------------------------------------

(ert-deftest kdn-faces/integration-surfaces ()
  (kdn-test--load-theme)
  (kdn-test--should-bg 'avy-lead-face-0 'dragonBlue2)
  (kdn-test--should-fg 'avy-background-face 'oldWhite)
  (kdn-test--should-fg 'consult-async-failed 'samuraiRed)
  (kdn-test--should-fg 'consult-key 'dragonYellow)
  (kdn-test--should-fg 'consult-line-number 'dragonBlack5)
  (kdn-test--should-fg 'embark-target 'dragonBlue2)
  (kdn-test--should-fg 'transient-key 'dragonYellow)
  (kdn-test--should-bg 'transient-enabled-suffix 'winterGreen)
  (kdn-test--should-bg 'transient-disabled-suffix 'winterRed)
  (kdn-test--should-bg 'ediff-current-diff-A 'winterRed)
  (kdn-test--should-bg 'ediff-current-diff-B 'winterGreen)
  (kdn-test--should-fg 'ediff-current-diff-C 'autumnYellow)
  (kdn-test--should-bg 'smerge-upper 'winterRed)
  (kdn-test--should-bg 'smerge-lower 'winterGreen)
  (kdn-test--should-fg 'smerge-markers 'dragonViolet))

(ert-deftest kdn-faces/wave-integration-surfaces ()
  (kdn-test--load-wave-theme)
  (kdn-test--wave-should-bg 'avy-lead-face-0 'crystalBlue)
  (kdn-test--wave-should-fg 'avy-background-face 'oldWhite)
  (kdn-test--wave-should-fg 'consult-async-failed 'samuraiRed)
  (kdn-test--wave-should-fg 'consult-key 'carpYellow)
  (kdn-test--wave-should-fg 'consult-line-number 'sumiInk5)
  (kdn-test--wave-should-fg 'embark-target 'crystalBlue)
  (kdn-test--wave-should-fg 'transient-key 'carpYellow)
  (kdn-test--wave-should-bg 'transient-enabled-suffix 'winterGreen)
  (kdn-test--wave-should-bg 'transient-disabled-suffix 'winterRed)
  (kdn-test--wave-should-bg 'ediff-current-diff-A 'winterRed)
  (kdn-test--wave-should-bg 'ediff-current-diff-B 'winterGreen)
  (kdn-test--wave-should-fg 'ediff-current-diff-C 'autumnYellow)
  (kdn-test--wave-should-bg 'smerge-upper 'winterRed)
  (kdn-test--wave-should-bg 'smerge-lower 'winterGreen)
  (kdn-test--wave-should-fg 'smerge-markers 'oniViolet))

;; ------------------------------------------------------------------
;; Structural invariants (both themes).  The 2026-09-12 audit noted
;; every face spec must be unique and well-formed; these tests encode
;; that invariant so a porting slip fails by name instead of shipping.
;; ------------------------------------------------------------------

(defun kdn-test--theme-face-entries (theme)
  "Return the (theme-face FACE THEME SPEC) entries recorded under THEME."
  (seq-filter (lambda (s) (eq (nth 0 s) 'theme-face))
              (get theme 'theme-settings)))

(defun kdn-test--collect-hexes (sexp)
  "Collect every #RGB or #RRGGBB string anywhere inside SEXP."
  (cond
   ((and (stringp sexp)
         (string-prefix-p "#" sexp)
         (member (length sexp) '(4 7)))
    (list sexp))
   ((consp sexp)
    (append (kdn-test--collect-hexes (car sexp))
            (kdn-test--collect-hexes (cdr sexp))))
   (t nil)))

(defvar kdn-test--palette-hexes
  (mapcar (lambda (e) (downcase (cdr e))) kanagawa-dragon-nvim-palette)
  "Lowercased palette hexes, for case-insensitive membership checks.")

(ert-deftest kdn-faces/face-specs-unique-per-theme ()
  "No face may be specified twice within one theme: a duplicated row
in a ported theme file would silently shadow its earlier entry."
  (kdn-test--load-theme)
  (kdn-test--load-wave-theme)
  (dolist (theme '(kanagawa-dragon-nvim kanagawa-wave-nvim))
    (let ((faces (mapcar (lambda (e) (nth 1 e))
                         (kdn-test--theme-face-entries theme))))
      (should (equal faces (seq-uniq faces))))))

(ert-deftest kdn-faces/dragon-and-wave-face-sets-identical ()
  "The family's core contract (spec Conformance rule 2): Wave sets the
identical face set Dragon sets, resolved through the Wave role values.
The 2026-09-13 audit verified the sets identical by hand but found
nothing enforcing it; a face added to one port and missed by the other
now fails here by name.  Generalizes to Lotus for free when it lands."
  (kdn-test--load-theme)
  (kdn-test--load-wave-theme)
  (let ((dragon-faces (mapcar (lambda (e) (nth 1 e))
                              (kdn-test--theme-face-entries 'kanagawa-dragon-nvim)))
        (wave-faces (mapcar (lambda (e) (nth 1 e))
                            (kdn-test--theme-face-entries 'kanagawa-wave-nvim))))
    (should (= (length dragon-faces) (length wave-faces)))
    (should (equal (sort (copy-sequence dragon-faces) #'string<)
                   (sort (copy-sequence wave-faces) #'string<)))))

(ert-deftest kdn-faces/every-hex-is-a-palette-member ()
  "Every hex literal in every face spec of both themes must be a
palette entry (case-insensitive).  Catches a typo'd or hand-rolled
hex slipping into a port."
  (kdn-test--load-theme)
  (kdn-test--load-wave-theme)
  (dolist (theme '(kanagawa-dragon-nvim kanagawa-wave-nvim))
    (dolist (entry (kdn-test--theme-face-entries theme))
      (dolist (hex (kdn-test--collect-hexes (nth 3 entry)))
        (unless (member (downcase hex) kdn-test--palette-hexes)
          (ert-fail (format "%s (%s): %s is not a palette member"
                            (nth 1 entry) theme hex)))))))

(provide 'test-faces)
;;; test-faces.el ends here
