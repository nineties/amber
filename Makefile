#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2012-06-11 11:38:22 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p /usr/lib/amber
	cp -r lib/* /usr/lib/amber/

doc-preview:
	cd doc; jekyll --server --safe

doc:
	cd doc; jekyll --no-auto --safe; rm -rf _deploy/*; cp -pr _site/* _deploy
	cd doc/_deploy; git add .; git commit -am 'update documents'; git push origin gh-pages
	git add .; git commit -m 'update documents'

clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean

.PHONY: all install clean doc doc-preview
