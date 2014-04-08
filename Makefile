#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2014-04-08 16:19:37 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	rm -rf /usr/lib/amber
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p /usr/lib/amber
	cp -r lib/* /usr/lib/amber/
	cp -r demo /usr/lib/amber/
	echo "exit" | amber --preparse

clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean

.PHONY: all install clean
