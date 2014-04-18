#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2014-04-19 01:20:39 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

install:
	cd rowl1; $(MAKE) install_binaries install_libraries
	mkdir -p $(LIBDIR)/amber
	cp -r lib/* $(LIBDIR)/amber
	@echo "Generating pre-parsed libs..."
	@echo exit | amber --preparse > /dev/null
	@echo "Installation finished."

clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean

.PHONY: all install clean
