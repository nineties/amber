#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-05-12 11:23:58 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_start

RLC0 = ../rlc0/rlc
SOURCES = startup.rl main.rl stddef.rl stdlib.rl alloc.rl rowllib.rl lex.rl

ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

alloc.s  : $(RLC0) stddef.s
main.s   : $(RLC0) stddef.s code.s
rowllib.s: $(RLC0) stddef.s
stdlib.s : $(RLC0) stddef.s
lex.s    : $(RLC0) stddef.s token.s

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

.SUFFIXES:
.SUFFIXES: .o .s .rl

.rl.s:
	$(RLC0) < $< > $@

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.PHONY: clean
clean:
	rm -f *.o *.s rlc core
