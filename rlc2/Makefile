#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-04-07 09:06:51 nineties $

LD = ld
LDFLAGS = --nostdlib --entry=main

RLC1 = ../rlc1/rlc
SOURCES = main.rl stdlib.rl
ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

main.o:   $(RLC1) main.rl stdlib.rli
stdlib.o: $(RLC1) stdlib.rl

.SUFFIXES:
.SUFFIXES: .o .rl .rli

.rl.rli:
	$(RLC1) $<

.rl.o:
	$(RLC1) $<

.PHONY: clean
clean:
	rm -f *.o *.s rlc core
