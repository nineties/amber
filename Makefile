#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-10-19 14:00:33 nineties $

all: 
	cd rowl0; $(MAKE)
	cd rowl1; $(MAKE)

.PHONY: clean
clean:
	cd rowl0; $(MAKE) clean
	cd rowl1; $(MAKE) clean
