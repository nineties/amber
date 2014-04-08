#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2014-04-08 22:35:19 nineties $

LIBDIR = /usr/lib/amber

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p $(LIBDIR)
	cp -ur lib/* $(LIBDIR)/
	cp -ur demo $(LIBDIR)/
	echo "exit" | amber --preparse

clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean

.PHONY: all install clean
