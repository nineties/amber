#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2014-04-08 19:38:26 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	rm -rf $(LIBDIR)
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p $(LIBDIR)
	cp -r lib/* $(LIBDIR)/
	cp -r demo $(LIBDIR)/
	echo "exit" | amber --preparse

clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean

.PHONY: all install clean
