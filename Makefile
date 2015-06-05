#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2015-06-05 22:54:18 nineties $

LIBDIR = /usr/lib

all: 
	cd rowl0; $(MAKE)
	cd amber; $(MAKE)

install:
	cd amber; $(MAKE) install_binaries install_libraries
	mkdir -p $(LIBDIR)/amber
	cp -ur lib/* $(LIBDIR)/amber
	@echo exit | amber --preparse > /dev/null
	@echo "Installation finished."

clean:
	cd rowl0; $(MAKE) clean
	cd amber; $(MAKE) clean

.PHONY: all install clean
