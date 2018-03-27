LSP-STYLES=~/Documents/Dienstlich/Projekte/OALI/Git-HUB/latex/langsci/

all: grammatical-theory.pdf


SOURCE=gt.bib \
	grammatical-theory.tex           \
	grammatical-theory-include.tex   \
	localmetadata.tex \
	localcommands.tex \
	localpackages.tex \
	backmatter.tex \
	chapters/1-begriffe.tex\
	chapters/2-psg.tex\
	chapters/3-gb.tex \
	chapters/3-minimalism.tex \
	chapters/4-gpsg.tex \
	chapters/5-merkmalstrukturen.tex \
	chapters/6-lfg.tex \
	chapters/7-cg.tex\
	chapters/8-hpsg.tex \
	chapters/9-cxg.tex \
	chapters/dg.tex\
	chapters/tag.tex\
	chapters/innateness.tex\
	chapters/acquisition.tex\
	chapters/complexity.tex\
	chapters/locality.tex\
	chapters/phrasal.tex\
	chapters/empty.tex\
	chapters/recursion.tex\
	chapters/conclusions.tex\
	chapters/loesungen.tex\
	chapters/versions.tex

.SUFFIXES: .tex


%.pdf: %.tex $(SOURCE)
	xelatex -no-pdf -interaction=nonstopmode $* |grep -v math
	bibtex $*
	xelatex -no-pdf -interaction=nonstopmode $* 
	bibtex $*
	xelatex -no-pdf -interaction=nonstopmode $*
	correct-index
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' *.sdx # ordering of references to footnotes
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' *.adx
	sed -i.backup 's/hyperindexformat{\\\(infn {[0-9]*\)}/\1/' *.ldx
	sed -i.backup 's/\\protect \\active@dq \\dq@prtct {=}/"=/g' *.adx
	sed -i.backup 's/{\\O }/Oe/' *.adx
	python3 fixindex.py
	mv $*mod.adx $*.adx
	makeindex -gs index.format-plus -o $*.and $*.adx
	makeindex -gs index.format -o $*.lnd $*.ldx
	makeindex -gs index.format -o $*.snd $*.sdx
	zhmakeindex -o $*.scd $*.scx
	xelatex $* | egrep -v 'math|PDFDocEncod|microtype' |egrep 'Warning|label|aux'



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


index:
	xelatex grammatical-theory -no-pdf |egrep -v 'math|PDFDocEncod' |egrep 'Warning|label|aux'
	makeindex -gs index.format -o grammatical-theory.snd grammatical-theory.sdx
	xelatex grammatical-theory |egrep -v 'math|PDFDocEncod' |egrep 'Warning|label|aux'



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




public: grammatical-theory.pdf
	cp $? /Users/stefan/public_html/Pub/


/Users/stefan/public_html/Pub/grammatical-theory.pdf: grammatical-theory.pdf
	cp -p $?                      /Users/stefan/public_html/Pub/grammatical-theory.pdf


commit:
	svn commit -m "published version to the web"

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


clean:
	rm -f *.bak *~ *.log *.blg *.bbl *.aux *.toc *.cut *.out *.tmp *.tpm *.adx *.idx *.ilg *.ind *.and *.glg *.glo *.gls *.657pk *.adx.hyp *.bbl.old *.ldx *.lnd *.rdx *.sdx *.snd *.wdx *.wdv *.xdv
	rm -f chapters/*~ chapters/*.aux

check-clean:
	rm -f *.bak *~ *.log *.blg complex-draft.dvi

realclean: clean
	rm -f *.dvi *.ps *.pdf



