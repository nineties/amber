TEX = platex
DVIPDFM = dvipdfmx
FIG2EPS = fig2eps --nogv

target: all

all: rowl_spec.pdf

rowl_spec.pdf:\
    rowl_spec.tex

%.eps : %.fig
	$(FIG2EPS) $<

%.pdf : %.dvi
	$(DVIPDFM) $<

%.dvi : %.tex
	nkf --overwrite -e $<
	$(TEX) $<
	$(TEX) $<
	nkf --overwrite -w $<

clean:
	rm -rf *.aux *.dvi *.log

.PHONY : all clean
