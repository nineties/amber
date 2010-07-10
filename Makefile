#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-07-11 01:08:54 nineties $

all: 
	cd rlc0; $(MAKE)
	cd rlc1; $(MAKE)

.PHONY: clean
clean:
	cd rlc0; $(MAKE) clean
	cd rlc1; $(MAKE) clean
	cd rlc2; $(MAKE) clean
