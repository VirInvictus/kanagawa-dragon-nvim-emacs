EMACS ?= emacs

.PHONY: test compile load load-wave clean

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

load:
	$(EMACS) -Q --batch \
		-L . \
		--eval "(add-to-list 'custom-theme-load-path default-directory)" \
		--eval "(load-theme 'kanagawa-dragon-nvim t)" \
		--eval "(message \"dragon theme loaded OK\")"

load-wave:
	$(EMACS) -Q --batch \
		-L . \
		--eval "(add-to-list 'custom-theme-load-path default-directory)" \
		--eval "(load-theme 'kanagawa-wave-nvim t)" \
		--eval "(message \"wave theme loaded OK\")"

clean:
	rm -f *.elc *.eln tests/*.elc tests/*.eln
