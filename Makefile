#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2012-01-19 22:55:46 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p /usr/lib/amber
	cp -r lib/* /usr/lib/amber/

.PHONY: clean
clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean
