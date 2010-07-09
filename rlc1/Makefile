#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-07-10 01:45:15 nineties $

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

vm-compile.o : stdlib.rlc vm-config.rlc
vm-main.o    : stdlib.rlc vm-compile.rlc
vm-eval.o    : stdlib.rlc vm-compile.rlc vm-insn.rlc vm-prim.rlc
vm-gc.o      : stdlib.rlc vm-compile.rlc
vm-load.o    : stdlib.rlc vm-compile.rlc

rlvm: vm-main.o vm-eval.o vm-gc.o vm-load.o vm-prim.o
	$(LD) $^ -o $@ $(VMLDFLAGS)

rlc1: rowl.rlc rlvm rlci rowl-compile.rlc rowl-assemble.rlc
	./rlci $< > $@

.SUFFIXES:
.SUFFIXES: .o .s .rl .rlc

.rl.s:
	$(RLC0) < $< > $@

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.rlc.s:
	./rlci $< > $@

.PHONY: clean
clean:
	rm -f *.o *.s rlci rlvm rlc1 core
