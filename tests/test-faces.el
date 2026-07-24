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

(provide 'test-faces)
;;; test-faces.el ends here
