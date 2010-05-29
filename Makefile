#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-05-29 11:45:20 nineties $

all: 
	cd rlc0; $(MAKE) rlc
	cd rlc1; $(MAKE) rlci

.PHONY: clean
clean:
	cd rlc0; $(MAKE) clean
	cd rlc1; $(MAKE) clean
	cd rlc2; $(MAKE) clean
