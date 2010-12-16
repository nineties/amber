#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-12-16 17:25:05 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p /usr/lib/rowl
	cp -r lib/* /usr/lib/rowl/

.PHONY: clean
clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean
