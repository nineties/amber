#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-01-27 20:56:25 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_main

RLC1 = ../rlc1/rlc
SOURCES = main.rl
ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

$(ASMSOURCES): $(RLC1)

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

.SUFFIXES: .rl

.rl.s:
	$(RLC1) $<

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.PHONY: clean
clean:
	rm -f *.o *.s rlc core
