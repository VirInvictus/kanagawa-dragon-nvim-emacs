;;; sample.el --- Visual eyeball buffer for elisp -*- lexical-binding: t; -*-

;; Open this in `emacs-lisp-mode' to eyeball comments, strings,
;; keywords, function names, and variable refs.

(require 'cl-lib)

(defconst sample-greetings
  '("hello" "konnichiwa" "bonjour" "guten tag")
  "A constant list of greetings to demonstrate strings and constants.")

(defvar sample-counter 0
  "A counter to demonstrate variable defs and references.")

(defun sample-greet (name &optional times)
  "Greet NAME, optionally TIMES many times.
Demonstrates docstrings, params, optional args, numbers, format calls."
  (let ((n (or times 1)))
    (cl-loop for i from 1 to n
             do (message "[%d] %s, %s!"
                         (cl-incf sample-counter)
                         (nth (mod i (length sample-greetings))
                              sample-greetings)
                         name))))

(when (> sample-counter -1)
  ;; A trivial branch to show keyword/operator/numeric coloring.
  (sample-greet "Brandon" 3))

(provide 'sample)
;;; sample.el ends here
