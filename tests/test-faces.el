;;; test-faces.el --- Representative face attribute checks -*- lexical-binding: t; -*-

;; Loads the theme into a batch Emacs and asserts that the face spec
;; recorded under the theme has the expected fg/bg from the spec.  This
;; doesn't enumerate every face — it spot-checks the ones whose mismatch
;; was the visible bug that motivated the project (Java treesit faces),
;; plus the load-bearing UI surfaces.
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
  "Load the theme without prompting in a batch session."
  (add-to-list 'custom-theme-load-path kdn-test--root)
  (load-theme 'kanagawa-dragon-nvim :no-confirm))

(defun kdn-test--face-spec-attr (face attr)
  "Pull ATTR (e.g. `:foreground') out of FACE's spec under the theme.
Reads from `theme-settings' so external faces that haven't been
`defface'd yet can still be verified."
  (let* ((settings (get 'kanagawa-dragon-nvim 'theme-settings))
         (entry (seq-find (lambda (s)
                            (and (eq (nth 0 s) 'theme-face)
                                 (eq (nth 1 s) face)))
                          settings)))
    (unless entry
      (error "kdn-test: theme has no spec for face %S" face))
    ;; entry shape: (theme-face FACE THEME SPEC)
    ;; SPEC shape: ((DISPLAY PLIST) ...) — we want the first plist's ATTR.
    (let* ((spec (nth 3 entry))
           (plist (cadr (car spec))))
      (plist-get plist attr))))

(defmacro kdn-test--should-fg (face palette-name)
  "Assert FACE's spec :foreground equals palette entry PALETTE-NAME."
  `(should (string-equal-ignore-case
            (kdn-test--face-spec-attr ,face :foreground)
            (kanagawa-dragon-nvim-color ,palette-name))))

(defmacro kdn-test--should-bg (face palette-name)
  "Assert FACE's spec :background equals palette entry PALETTE-NAME."
  `(should (string-equal-ignore-case
            (kdn-test--face-spec-attr ,face :background)
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

(ert-deftest kdn-faces/solaire-bg-darker-than-default ()
  "Solaire's slightly-darker bg is what makes Doom buffers feel right —
guard against accidentally using `bg' itself."
  (kdn-test--load-theme)
  (kdn-test--should-bg 'solaire-default-face 'dragonBlack2)
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
and term/vterm reuse the same mapping."
  (kdn-test--load-theme)
  (kdn-test--should-fg 'ansi-color-bright-red     'waveRed)
  (kdn-test--should-fg 'ansi-color-bright-green   'dragonGreen)
  (kdn-test--should-fg 'ansi-color-bright-yellow  'carpYellow)
  (kdn-test--should-fg 'ansi-color-bright-blue    'springBlue)
  (kdn-test--should-fg 'ansi-color-bright-magenta 'springViolet1)
  (kdn-test--should-fg 'ansi-color-bright-cyan    'waveAqua2)
  (kdn-test--should-fg 'term-color-red            'dragonRed)
  (kdn-test--should-fg 'term-color-cyan           'dragonAqua)
  (kdn-test--should-fg 'vterm-color-green         'dragonGreen2))

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

(provide 'test-faces)
;;; test-faces.el ends here
