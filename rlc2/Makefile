#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-05-07 11:04:19 nineties $

LD = ld
LDFLAGS = --nostdlib --entry=__start

RLC1 = ../rlc1/rlc
#SOURCES =\
#	 startup.rl \
#	 main.rl \
#	 sys.rl \
#	 alloc.rl \
#	 string.rl \
#	 io.rl \
#	 stdlib.rl
SOURCES = main.rl

ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

startup.o: $(RLC1) startup.rl main.o stdlib.o
main.o   : $(RLC1) main.rl io.o stdlib.o
sys.o    : $(RLC1) sys.rl
alloc.o  : $(RLC1) alloc.rl sys.o
stdlib.o : $(RLC1) stdlib.rl sys.o alloc.o
string.o : $(RLC1) string.rl
io.o     : $(RLC1) io.rl sys.o alloc.o string.o

.SUFFIXES:
.SUFFIXES: .o .rl .rli

.rl.rli:
	$(RLC1) $<

.rl.o:
	$(RLC1) $<

.PHONY: clean
clean:
	rm -f *.rli *.o *.s rlc core
