default: Thesis.pdf

.PHONY: clean
clean:
	latexmk -C
	rm -f *.bbl *.run.xml tex/*.aux creationdate.lua Thesis.tex

# We can't enable pdfa for hyperref after calling \usepackage{hyperref},
# so we need to have custom 'org-latex-default-packages-alist
Thesis.tex: Thesis.org
	emacs --batch --eval="\
	(progn\
	  (require 'org)\
	  (setq enable-local-variables :all)\
	  (setq enable-local-eval t)\
	  (with-current-buffer\
	    (find-file \"$<\")\
	    (org-latex-export-to-latex)))"

Thesis.pdf: Thesis.tex tex/*.tex bibliography.bib
	latexmk -interaction=nonstopmode -pdf -lualatex $(PREVIEW_CONTINUOUSLY) $<

.PHONY: watch
watch: PREVIEW_CONTINUOUSLY=-pvc
watch: Thesis.pdf

.PHONY: docker-verify
docker-verify: Thesis.pdf
	docker run -v "${PWD}:/thesis" ghcr.io/vojtechstep/cuni-thesis-validator verify /thesis/Thesis.pdf
