#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2012-06-11 10:37:45 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p /usr/lib/amber
	cp -r lib/* /usr/lib/amber/

doc:
	cd doc; jekyll --no-auto
	cd doc/_site; git add .; git commit -am 'update documents'; git push origin gh-pages
	git add .; git commit -m 'update documents'

clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean

.PHONY: all install clean doc
