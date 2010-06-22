#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-06-22 16:46:13 nineties $

all: 
	cd rlc0; $(MAKE) rlc
	cd rlc1; $(MAKE) rlci rlvm rlc1

.PHONY: clean
clean:
	cd rlc0; $(MAKE) clean
	cd rlc1; $(MAKE) clean
	cd rlc2; $(MAKE) clean
