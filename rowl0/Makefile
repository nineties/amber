#
# rowl - 
# Copyright (C) 2009 nineties
#

# $Id: Makefile 2010-01-15 03:29:08 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_main

all: rlc

rlc: main.o lib.o lex.o compile.o codegen.o
	$(LD) $^ -o $@ $(LDFLAGS)

main.o: main.s defs.s token.s
lib.o: lib.s defs.s
lex.o: lex.s defs.s token.s 
compile.o: compile.s defs.s token.s 
codegen.o: codegen.s defs.s token.s

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.PHONY: clean
clean:
	rm -f *.o rlc core
