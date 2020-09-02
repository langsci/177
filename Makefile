LSP-STYLES=~/Documents/Dienstlich/Projekte/OALI/Git-HUB/latex/langsci/

# if you do not have a ~/bin/ directory already, do
# mkdir ~/bin
# and move zhmakeindex there
ZHMAKEINDEX-PATH=~/bin/

# I remove gt.bib here since others do not have my bibliography files
SOURCE= $(wildcard local*.tex) $(wildcard *.sty) $(wildcard chapters/*.tex)	grammatical-theory.tex           \
	grammatical-theory-include.tex   \
	backmatter.tex 

.SUFFIXES: .tex


all: grammatical-theory.pdf



%.pdf: %.tex $(SOURCE)
	xelatex -no-pdf -interaction=nonstopmode $* |grep -v math
	biber $*
	xelatex -no-pdf -interaction=nonstopmode $* 
	biber $*
	xelatex -no-pdf -interaction=nonstopmode $*
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' *.sdx # ordering of references to footnotes
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' *.ldx
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' *.ldxe
	sed -i.backup 's/\\MakeCapital //g' *.adx
	python3 fixindex.py $*.adx
	mv $*mod.adx $*.adx
	makeindex -gs index.format-plus -o $*.and $*.adx
	$(ZHMAKEINDEX-PATH)zhmakeindex -o $*.lnd $*.ldx
	makeindex -gs index.format -o $*.lnde $*.ldxe
	$(ZHMAKEINDEX-PATH)zhmakeindex -o $*.snd $*.sdx
	makeindex -gs index.format -o $*.scd $*.scx
	xelatex $* | egrep -v 'math|PDFDocEncod|microtype' |egrep 'Warning|label'




stable.pdf: main.pdf
	cp main.pdf stable.pdf

test-zhmakeindex: 
	$(ZHMAKEINDEX-PATH)zhmakeindex -o grammatical-theory.scd grammatical-theory.scx

subject-index:
	xelatex grammatical-theory.tex
	makeindex -gs index.format -o grammatical-theory.snd grammatical-theory.sdx
	$(ZHMAKEINDEX-PATH)zhmakeindex -o grammatical-theory.scd grammatical-theory.scx
	xelatex grammatical-theory.tex


author-index:
	xelatex grammatical-theory.tex
	sed -i.backup 's/\\MakeCapital //g' grammatical-theory.adx
	python3 fixindex.py grammatical-theory.adx
	mv grammatical-theorymod.adx grammatical-theory.adx
	makeindex -gs index.format-plus -o grammatical-theory.and grammatical-theory.adx
	xelatex grammatical-theory.tex


proofreading: proofreading.pdf


proofreading.pdf: grammatical-theory.pdf
	pdftk grammatical-theory.pdf multistamp prstamp.pdf output proofreading.pdf 

# removed this. It was about Umlaute	bin/correct-index


# %.pdf: %.tex $(SOURCE)
# 	xelatex -no-pdf -interaction=nonstopmode $* |grep -v math
# 	bibtex  -min-crossrefs=200 $*
# 	xelatex -no-pdf -interaction=nonstopmode $* 
# 	bibtex  -min-crossrefs=200 $*
# 	xelatex -no-pdf -interaction=nonstopmode $*
# 	correct-toappear
# 	correct-index
# 	\rm $*.adx
# 	authorindex -i -p $*.aux > $*.adx
# 	sed -e 's/}{/|hyperpage}{/g' $*.adx > $*.adx.hyp
# 	makeindex -gs index.format-plus -o $*.and $*.adx.hyp
# 	makeindex -gs index.format -o $*.lnd $*.ldx
# 	makeindex -gs index.format -o $*.snd $*.sdx
# 	xelatex $* 


#	xelatex $* -no-pdf -interaction=nonstopmode

bbl:
	xelatex -no-pdf -interaction=nonstopmode grammatical-theory
	bib  -min-crossrefs=200 grammatical-theory
	xelatex -no-pdf -interaction=nonstopmode grammatical-theory
	bibtex  -min-crossrefs=200 grammatical-theory
	bin/correct-toappear

#	xelatex $* -no-pdf |egrep -v 'math|PDFDocEncod|microtype' |egrep 'Warning|label|aux'


# idx = author index
# ldx = language
# sdx = subject

# mit biblatex
#	makeindex -gs index.format -o $*.ind $*.idx


#	\rm $*.adx
#	authorindex -i -p $*.aux > $*.adx
#	sed -e 's/}{/|hyperpage}{/g' $*.adx > $*.adx.hyp
#	makeindex -gs index.format -o $*.and $*.adx.hyp
#	xelatex $* | egrep -v 'math|PDFDocEncod' |egrep 'Warning|label|aux'





check-index:
	xelatex check-gt-chinese
	zhmakeindex -o check-gt-chinese.scd check-gt-chinese.scx
	xelatex check-gt-chinese

# mit neu langsci.cls
# %.pdf: %.tex $(SOURCE)
# 	xelatex -no-pdf $* |grep -v math
# 	bibtex $*
# 	xelatex -no-pdf $* |grep -v math
# 	bibtex $*
# 	xelatex $* -no-pdf |egrep -v 'math|PDFDocEncod' |egrep 'Warning|label|aux'
# 	correct-toappear
# 	correct-index
# 	sed -i s/.*\\emph.*// lsp-skeleton.adx #remove titles which biblatex puts into the name index
# 	makeindex -o $*.and $*.adx
# 	makeindex -o $*.lnd $*.ldx
# 	makeindex -o $*.snd $*.sdx
# 	xelatex $* | egrep -v 'math|PDFDocEncod' |egrep 'Warning|label|aux'



# http://stackoverflow.com/questions/10934456/imagemagick-pdf-to-jpgs-sometimes-results-in-black-background
cover: grammatical-theory.pdf
	convert $<\[0\] -resize 486x -background white -alpha remove -bordercolor black -border 2  cover.png


# fuer Sprachenindex
#	makeindex -gs index.format -o $*.lnd $*.ldx

lsp-styles:
	rsync -a $(LSP-STYLES) langsci

# before calling this load nomemoize in grammatical theory
# we need three runs to get the trees right ....
memos1: cleanmemo
	rm grammatical-theory.bbl; rm grammatical-theory.bcf
	xelatex -no-pdf grammatical-theory
	xelatex -no-pdf grammatical-theory
	xelatex grammatical-theory

# before calling this load memoize in grammatical theory
memos2:
	xelatex -shell-escape grammatical-theory
	python3 memomanager.py split grammatical-theory.mmz
	biber grammatical-theory
	xelatex -shell-escape grammatical-theory

# to eliminate the risk of jumping trees build the complete pdf without
# memozation (main.tex does load nomemoize) and then latex compile-memos-grammatical-theory.tex
# (which does load memoize, ignores \addlines and does not have the bibliography compiled) and call the extraction script after this.
# call with "make -i" to ignore all errors that may be caused to latex runs.
# If xelatex cannot extract the memos recorded during the firt run, it would otherwise fail,
# but we need at least two runs to get the jumping trees to stabilaze
memos: cleanmemo 
	xelatex -interaction=nonstopmode compile-memos-grammatical-theory
	rm compile-memos-grammatical-theory.mmz # we do not want to extract yet
	xelatex -interaction=nonstopmode compile-memos-grammatical-theory
	python3 memomanager.py split compile-memos-grammatical-theory.mmz


public: grammatical-theory.pdf
	cp $? /Users/stefan/public_html/Pub/


/Users/stefan/public_html/Pub/grammatical-theory.pdf: grammatical-theory.pdf
	cp -p $?                      /Users/stefan/public_html/Pub/grammatical-theory.pdf


commit-stable: stable.pdf
	git commit -m "automatic creation of stable.pdf" stable.pdf
	git push -u origin




o-public: o-public-lehrbuch 
#o-public-bib

o-public-lehrbuch: /Users/stefan/public_html/Pub/grammatical-theory.pdf 
	scp -p $? home.hpsg.fu-berlin.de:/home/stefan/public_html/Pub/


# two runs in order to get "also printed as ..." right
# gt.bib for chinese book was created inthe beginning. Is not touched now.
# gt.bib: ../../../Bibliographien/biblio.bib
# 	xelatex -no-pdf -interaction=nonstopmode bib-creation 
# 	bibtex bib-creation
# 	xelatex -no-pdf -interaction=nonstopmode bib-creation 
# 	bibtool -r ../../../Bibliographien/.bibtool77-no-comments  -x bib-creation.aux -o gt-tmp.bib
# 	cat ../../../Bibliographien/bib-abbr.bib gt-tmp.bib > gt.bib
# 	\rm -r gt-tmp.bib

gt.bib: ../../../Bibliographien/biblio.bib $(SOURCE)
	xelatex -no-pdf -interaction=nonstopmode -shell-escape bib-creation 
	biber bib-creation
	xelatex -no-pdf -interaction=nonstopmode -shell-escape bib-creation
	biber --output_format=bibtex bib-creation.bcf -O gt_tmp.bib
	biber --tool --configfile=biber-tool.conf --output-field-replace=location:address,journaltitle:journal --output-legacy-date gt_tmp.bib -O gt.bib


PUB_FILE=stmue.bib

o-public-bib: $(PUB_FILE)
	scp -p $? home.hpsg.fu-berlin.de:/home/stefan/public_html/Pub/






#-f '(author){%n(author)}{%n(editor)}:{%2d(year)#%s(year)#no-year}'

#$(IN_FILE).dvi
$(PUB_FILE): ../../hpsg/make_bib_header ../../hpsg/make_bib_html_number  ../../hpsg/.bibtool77-no-comments grammatical-theory.aux ../../hpsg/la.aux ../../HPSG-Lehrbuch/hpsg-lehrbuch-3.aux ../../complex/complex-csli.aux ../../../Bibliographien/biblio.bib
	sort -u grammatical-theory.aux ../../hpsg/la.aux ../../HPSG-Lehrbuch/hpsg-lehrbuch-3.aux ../../complex/complex-csli.aux  >tmp.aux
	bibtool -r ../../hpsg/.bibtool77-no-comments  -x tmp.aux -o $(PUB_FILE).tmp
	sed -e 's/-u//g'  $(PUB_FILE).tmp  >$(PUB_FILE).tmp.neu
	../../hpsg/make_bib_header
	cat bib_header.txt $(PUB_FILE).tmp.neu > $(PUB_FILE)
	rm $(PUB_FILE).tmp $(PUB_FILE).tmp.neu


source: 
	tar chzvf ~/Downloads/gt.tgz *.tex styles/*.sty LSP/


memo-install:
	cp -pr ~/Documents/Dienstlich/Projekte/memoize/memoize* .
	cp -pr ~/Documents/Dienstlich/Projekte/memoize/nomemoize* .
	cp -pr ~/Documents/Dienstlich/Projekte/memoize/xparse-arglist.sty .
	cp -pr ~/Documents/Dienstlich/Projekte/memoize/memomanager.py .

#housekeeping	
clean:
	rm -f *.bak *~ *.backup \
	*.adx *.and *.idx *.ind *.ldx *.lnd *.sdx *.snd *.rdx *.rnd *.wdx *.wnd \
	*.log *.blg *.bcf *.aux.copy *.auxlock *.ilg \
	*.aux *.toc *.cut *.out *.tpm *.bbl *-blx.bib *_tmp.bib \
	*.glg *.glo *.gls *.wrd *.wdv *.xdv *.mw *.clr \
	*.run.xml *.scd *.scx *.ldxe *.lnde \
	chapters/*.aux chapters/*.auxlock chapters/*.aux.copy chapters/*.old chapters/*~ chapters/*.bak chapters/*.backup chapters/*.blg\
	chapters/*.log chapters/*.out chapters/*.mw chapters/*.ldx  chapters/*.bbl chapters/*.bcf chapters/*.run.xml\
	chapters/*.blg chapters/*.idx chapters/*.sdx chapters/*.run.xml chapters/*.adx chapters/*.ldx\
	langsci/*/*.aux langsci/*/*~ langsci/*/*.bak langsci/*/*.backup \
	cuts.txt

realclean: clean
	rm -f *.dvi *.ps *.pdf chapters/*.pdf

cleanmemo:
	rm -f *.mmz *.memo.dir/*

brutal-clean: realclean cleanmemo

check-clean:
	rm -f *.bak *~ *.log *.blg complex-draft.dvi




