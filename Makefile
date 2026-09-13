EMACS ?= emacs

.PHONY: test compile clean

test:
	$(EMACS) -Q --batch \
		-L . \
		-l tests/test-palette.el \
		-l tests/test-faces.el \
		-f ert-run-tests-batch-and-exit

compile:
	$(EMACS) -Q --batch \
		-L . \
		--eval '(setq byte-compile-error-on-warn t)' \
		-f batch-byte-compile \
		kanagawa-dragon-nvim.el kanagawa-dragon-nvim-theme.el kanagawa-wave-nvim-theme.el

clean:
	rm -f *.elc tests/*.elc
