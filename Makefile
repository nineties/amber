#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-09-28 11:38:56 nineties $

all: 
	cd rlc0; $(MAKE)
	cd rlc1; $(MAKE)

.PHONY: clean
clean:
	cd rlc0; $(MAKE) clean
	cd rlc1; $(MAKE) clean
