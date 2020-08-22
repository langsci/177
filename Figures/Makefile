

%.pdf: %.tex
	lualatex $*
	lualatex $*
	pdfcrop $*

clean:
	rm -f *.bak *~ *.log *.blg *.bbl *.aux *.toc *.cut *.out *.tmp *.tpm *.adx *.idx *.ilg *.ind\
	*.and *.glg *.glo *.gls *.657pk *.adx.hyp *.bbl.old *.ldx *.lnd *.rdx *.sdx *.snd *.wdx\
	*.wdv *.xdv *.aux.copy *.bcf *.for *.mw *.scx *.run.xml *.for



#realclean: clean
#	rm -f *.dvi *.ps *.pdf



