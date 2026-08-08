;;; kanagawa-dragon-nvim.el --- Dragon palette helper -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Brandon Larocque
;; Author: Brandon Larocque
;; Version: 0.1.3
;; Package-Requires: ((emacs "29.1"))
;; Keywords: faces, theme
;; URL: https://github.com/bdkl/kanagawa-dragon-nvim-emacs
;; SPDX-License-Identifier: MIT

;;; Commentary:

;; Palette helper plus optional setup utilities for
;; `kanagawa-dragon-nvim-theme'.  Exposes the Dragon palette as an
;; alist so other code (statuslines, packages that render with a
;; custom palette, ports of the same theme to other UI surfaces) can
;; reuse the exact hex values without reimplementing them.
;;
;; Loading this file does not enable the theme.  Use
;; `(load-theme 'kanagawa-dragon-nvim t)' for that.
;;
;; Optional helper:
;; `kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed' fixes a
;; long-standing lsp-mode quirk where semantic-token modifiers
;; (`declaration', `readonly', etc.) are mapped to *colored* type
;; faces.  Face composition prepends modifier faces, so the modifier
;; colour overrides the base token colour.  See the function's
;; docstring for the full mechanism and the recommended call site.

;;; Code:

(defconst kanagawa-dragon-nvim-version "0.1.3"
  "Version of kanagawa-dragon-nvim.  Kept in lockstep with the VERSION file.")

(defconst kanagawa-dragon-nvim-palette
  '(;; Dragon backgrounds (cool->warm darks)
    (dragonBlack0  . "#0d0c0c")
    (dragonBlack1  . "#12120f")
    (dragonBlack2  . "#1D1C19")
    (dragonBlack3  . "#181616")
    (dragonBlack4  . "#282727")
    (dragonBlack5  . "#393836")
    (dragonBlack6  . "#625e5a")
    ;; Dragon foregrounds + accents
    (dragonWhite   . "#c5c9c5")
    (dragonGreen   . "#87a987")
    (dragonGreen2  . "#8a9a7b")
    (dragonPink    . "#a292a3")
    (dragonOrange  . "#b6927b")
    (dragonOrange2 . "#b98d7b")
    (dragonGray    . "#a6a69c")
    (dragonGray2   . "#9e9b93")
    (dragonGray3   . "#7a8382")
    (dragonBlue2   . "#8ba4b0")
    (dragonViolet  . "#8992a7")
    (dragonRed     . "#c4746e")
    (dragonAqua    . "#8ea4a2")
    (dragonAsh     . "#737c73")
    (dragonTeal    . "#949fb5")
    (dragonYellow  . "#c4b28a")
    ;; Shared (Wave-origin) entries used by Dragon's mapping
    (dragonBlue    . "#658594")
    (fujiWhite     . "#DCD7BA")
    (oldWhite      . "#C8C093")
    (fujiGray      . "#727169")
    (katanaGray    . "#717C7C")
    (sumiInk6      . "#54546D")
    (waveBlue1     . "#223249")
    (waveBlue2     . "#2D4F67")
    (waveAqua1     . "#6A9589")
    (waveAqua2     . "#7AA89F")
    (waveRed       . "#E46876")
    (springGreen   . "#98BB6C")
    (springBlue    . "#7FB4CA")
    (springViolet1 . "#938AA9")
    (carpYellow    . "#E6C384")
    (samuraiRed    . "#E82424")
    (roninYellow   . "#FF9E3B")
    (winterRed     . "#43242B")
    (winterGreen   . "#2B3328")
    (winterYellow  . "#49443C")
    (winterBlue    . "#252535")
    (autumnRed     . "#C34043")
    (autumnGreen   . "#76946A")
    (autumnYellow  . "#DCA561"))
  "Kanagawa Dragon palette.
Hex values reproduced verbatim from
`kanagawa.nvim/lua/kanagawa/colors.lua' upstream.  Names match upstream
casing exactly so the spec can be cross-referenced mechanically.")

(defun kanagawa-dragon-nvim-color (name)
  "Return the hex string for palette entry NAME (a symbol)."
  (or (cdr (assq name kanagawa-dragon-nvim-palette))
      (error "kanagawa-dragon-nvim: unknown palette entry %S" name)))


;;;; LSP semantic-tokens modifier-bleed fix

;; `lsp-mode' maps several semantic-token *modifiers* (declaration,
;; readonly, abstract, async, modification, documentation) to *colored*
;; type faces in `lsp-semantic-token-modifier-faces': declaration →
;; `lsp-face-semhl-interface' (aqua), readonly → `lsp-face-semhl-constant'
;; (orange), and so on.  When `add-face-text-property' composes the
;; modifier face on top of the base token face, the modifier face is
;; *prepended* in the resulting face list — and first-wins composition
;; means the modifier's colour overrides the base.
;;
;; For Java (and every language whose LSP server emits the `declaration'
;; modifier) every declared field, method name, and local takes on the
;; modifier face's colour instead of its base token colour.  Whole
;; declaration lines collapse to a single tint.
;;
;; The fix is purely a variable rebind: repoint the bleeding entries at
;; an empty face so the modifier signal is preserved (it's still applied
;; as a face overlay) but no longer paints a colour.

(defface kanagawa-dragon-nvim-lsp-modifier-noop
  '((t nil))
  "Empty face used to neutralize `lsp-semantic-token-modifier-faces'.
Substituted into bleeding modifier entries by
`kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed' so the modifier no
longer overrides the base token colour.")

;; Declared so byte-compile doesn't warn on the reference inside the
;; helper. Real binding comes from `lsp-semantic-tokens' when that
;; package is loaded; the helper signals a `user-error' if it isn't.
(defvar lsp-semantic-token-modifier-faces)

(defconst kanagawa-dragon-nvim-lsp-bleeding-modifiers
  '("declaration" "readonly" "abstract" "async" "modification" "documentation")
  "lsp-mode semantic-token modifier names whose default face mapping
overrides the base token colour via face composition.

The five other standard modifiers (`definition', `implementation',
`defaultLibrary', `static', `deprecated') already map to dedicated
modifier faces with no inherent colour, so they don't bleed and are
left alone.")

(defun kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed ()
  "Stop lsp-mode's modifier→type-face mapping from overwriting base colours.

By default, `lsp-mode' maps semantic-token modifiers like \"declaration\"
to colored type faces (e.g. `lsp-face-semhl-interface').  When
`add-face-text-property' composes the modifier on top of the base, the
modifier's colour wins and the base token colour is lost.

This function repoints the bleeding modifiers (see
`kanagawa-dragon-nvim-lsp-bleeding-modifiers') at the empty face
`kanagawa-dragon-nvim-lsp-modifier-noop'.  Idempotent.

Recommended call site:

  (with-eval-after-load \\='lsp-semantic-tokens
    (kanagawa-dragon-nvim-neutralize-lsp-modifier-bleed))"
  (unless (boundp 'lsp-semantic-token-modifier-faces)
    (user-error "kanagawa-dragon-nvim: `lsp-semantic-token-modifier-faces' is not bound — call this inside `with-eval-after-load' on `lsp-semantic-tokens'"))
  (dolist (mod kanagawa-dragon-nvim-lsp-bleeding-modifiers)
    (when-let ((cell (assoc mod lsp-semantic-token-modifier-faces)))
      (setcdr cell 'kanagawa-dragon-nvim-lsp-modifier-noop))))

(provide 'kanagawa-dragon-nvim)

;;; kanagawa-dragon-nvim.el ends here
