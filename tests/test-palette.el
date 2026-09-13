;;; test-palette.el --- Palette integrity tests -*- lexical-binding: t; -*-

;; Verifies the Dragon palette in `kanagawa-dragon-nvim.el' matches the
;; upstream nvim source (kanagawa.nvim/lua/kanagawa/colors.lua) byte-for-
;; byte.  Run with:
;;
;;   make test
;;
;; or:
;;
;;   emacs -Q --batch -L . -l tests/test-palette.el -f ert-run-tests-batch-and-exit

;;; Code:

(require 'ert)
(require 'kanagawa-dragon-nvim)

;; Capture the repo root at load time — `load-file-name' is only bound
;; while the file is being loaded, not when ERT runs the tests later.
(defconst kdn-test-palette--root
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name))))
  "Absolute path to the repo root, captured at load time.")

(defconst kdn-test--upstream-dragon-palette
  '((dragonBlack0  . "#0d0c0c")
    (dragonBlack1  . "#12120f")
    (dragonBlack2  . "#1D1C19")
    (dragonBlack3  . "#181616")
    (dragonBlack4  . "#282727")
    (dragonBlack5  . "#393836")
    (dragonBlack6  . "#625e5a")
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
    (dragonYellow  . "#c4b28a"))
  "Dragon-specific palette as it appears in upstream colors.lua.
If upstream changes, sync this constant in lockstep with the palette.")

(defconst kdn-test--upstream-wave-palette
  '((sumiInk0      . "#16161D")
    (sumiInk1      . "#181820")
    (sumiInk2      . "#1a1a22")
    (sumiInk3      . "#1F1F28")
    (sumiInk4      . "#2A2A37")
    (sumiInk5      . "#363646")
    (oniViolet     . "#957FB8")
    (oniViolet2    . "#b8b4d0")
    (crystalBlue   . "#7E9CD8")
    (springViolet2 . "#9CABCA")
    (sakuraPink    . "#D27E99")
    (surimiOrange  . "#FFA066")
    (peachRed      . "#FF5D62")
    (boatYellow2   . "#C0A36E"))
  "Wave-specific palette as it appears in upstream colors.lua
(sumi background ladder plus the wave accents the wave theme adds on
top of the shared pool).  If upstream changes, sync this constant in
lockstep with the palette.")

(defconst kdn-test--upstream-shared-palette
  '((dragonBlue    . "#658594")
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
  "Shared (Wave-origin) palette entries used by Dragon's mapping.")

(ert-deftest kdn-palette/every-dragon-entry-matches-upstream ()
  "Every upstream Dragon hex is reproduced byte-for-byte."
  (dolist (entry kdn-test--upstream-dragon-palette)
    (let* ((name (car entry))
           (expected (cdr entry))
           (actual (cdr (assq name kanagawa-dragon-nvim-palette))))
      (should actual)
      (should (string= expected actual)))))

(ert-deftest kdn-palette/every-shared-entry-matches-upstream ()
  "Every shared (Wave-origin) hex used by Dragon matches upstream."
  (dolist (entry kdn-test--upstream-shared-palette)
    (let* ((name (car entry))
           (expected (cdr entry))
           (actual (cdr (assq name kanagawa-dragon-nvim-palette))))
      (should actual)
      (should (string= expected actual)))))

(ert-deftest kdn-palette/every-wave-entry-matches-upstream ()
  "Every Wave-specific hex is reproduced byte-for-byte."
  (dolist (entry kdn-test--upstream-wave-palette)
    (let* ((name (car entry))
           (expected (cdr entry))
           (actual (cdr (assq name kanagawa-dragon-nvim-palette))))
      (should actual)
      (should (string= expected actual)))))

(ert-deftest kdn-palette/no-stray-entries ()
  "Palette contains exactly the union of dragon + wave + shared
entries — no unexpected names that drifted in.  Catches typos like a
stray `dragonBlu'."
  (let ((expected-names
         (append (mapcar #'car kdn-test--upstream-dragon-palette)
                 (mapcar #'car kdn-test--upstream-wave-palette)
                 (mapcar #'car kdn-test--upstream-shared-palette)))
        (actual-names (mapcar #'car kanagawa-dragon-nvim-palette)))
    (should (equal (sort (copy-sequence expected-names) #'string<)
                   (sort (copy-sequence actual-names) #'string<)))))

(ert-deftest kdn-palette/color-lookup-helper ()
  "`kanagawa-dragon-nvim-color' returns hex for known names and errors
for unknown names."
  (should (string= "#181616" (kanagawa-dragon-nvim-color 'dragonBlack3)))
  (should (string= "#8a9a7b" (kanagawa-dragon-nvim-color 'dragonGreen2)))
  (should-error (kanagawa-dragon-nvim-color 'definitelyNotAColor)))

(ert-deftest kdn-palette/version-matches-version-file ()
  "Version constant matches the VERSION file at repo root."
  (let* ((version-file (expand-file-name "VERSION" kdn-test-palette--root))
         (file-version (with-temp-buffer
                         (insert-file-contents version-file)
                         (string-trim (buffer-string)))))
    (should (string= file-version kanagawa-dragon-nvim-version))))

(provide 'test-palette)
;;; test-palette.el ends here
