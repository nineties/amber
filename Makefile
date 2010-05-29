#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-05-29 15:53:51 nineties $

all: 
	cd rlc0; $(MAKE) rlc
	cd rlc1; $(MAKE) rlci rlvm

.PHONY: clean
clean:
	cd rlc0; $(MAKE) clean
	cd rlc1; $(MAKE) clean
	cd rlc2; $(MAKE) clean
