#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-04-10 12:35:55 nineties $

LD = ld
LDFLAGS = --nostdlib --entry=main

RLC1 = ../rlc1/rlc
SOURCES = main.rl sys.rl alloc.rl stdlib.rl
ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

main.o   : $(RLC1) main.rl stdlib.o
sys.o    : $(RLC1) sys.rl
alloc.o  : $(RLC1) sys.o
stdlib.o : $(RLC1) sys.o alloc.o stdlib.rl
string.o : $(RLC1)
io.o     : $(RLC1)

.SUFFIXES:
.SUFFIXES: .o .rl .rli

.rl.rli:
	$(RLC1) $<

.rl.o:
	$(RLC1) $<

.PHONY: clean
clean:
	rm -f *.rli *.o *.s rlc core
