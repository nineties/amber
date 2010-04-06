#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-04-06 18:01:36 nineties $

LD = ld
LDFLAGS = --nostdlib --entry=main

RLC1 = ../rlc1/rlc
SOURCES = main.rl
ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

main.o: $(RLC1) main.rl

.SUFFIXES:
.SUFFIXES: .o .rl

.rl.o:
	$(RLC1) $<

.PHONY: clean
clean:
	rm -f *.o *.s rlc core
