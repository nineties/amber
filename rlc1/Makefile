#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-06-02 21:34:10 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_start

RLC0 = ../rlc0/rlc
SOURCES = startup.rl\
	  main.rl\
	  stddef.rl\
	  stdlib.rl\
	  alloc.rl\
	  rowllib.rl\
	  builtin.rl\
	  pprint.rl\
	  lex.rl\
	  parse.rl\
	  eval.rl

ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

alloc.s  : $(RLC0) stddef.s
main.s   : $(RLC0) stddef.s code.s
rowllib.s: $(RLC0) stddef.s
stdlib.s : $(RLC0) stddef.s
builtin.s: $(RLC0) stddef.s code.s
pprint.s : $(RLC0) stddef.s code.s
lex.s    : $(RLC0) stddef.s token.s
parse.s  : $(RLC0) stddef.s token.s code.s
eval.s   : $(RLC0) stddef.s code.s

rlci: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)


VMLDFLAGS = --nostdlib --entry=_start

rlvm: vm.o
	$(LD) vm.o -o $@ $(VMLDFLAGS)

vm.s: rlci vmgen.rlc vm-main.rlc vm-gc.rlc stdlib.rlc
	./rlci vmgen.rlc > $@

.SUFFIXES:
.SUFFIXES: .o .s .rl

.rl.s:
	$(RLC0) < $< > $@

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.PHONY: clean
clean:
	rm -f *.o *.s rlci rlvm core
