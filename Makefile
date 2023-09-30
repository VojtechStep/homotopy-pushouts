.PHONY: clean
clean:
	latexmk -C
	rm -f *.bbl *.run.xml Thesis.tex

Thesis.tex: Thesis.org
	emacs --batch --eval="\
	(progn\
	  (require 'org)\
	  (with-current-buffer\
	    (find-file \"$<\")\
	    (org-latex-export-to-latex)))"

Thesis.pdf: Thesis.tex bibliography.bib
	latexmk -interaction=nonstopmode -pdf -lualatex $<
