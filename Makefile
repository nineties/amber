#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-05-18 02:35:09 nineties $

all: 
	cd rlc0; $(MAKE) rlc
	cd rlc1; $(MAKE) rlc

.PHONY: clean
clean:
	cd rlc0; $(MAKE) clean
	cd rlc1; $(MAKE) clean
	cd rlc2; $(MAKE) clean
