#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-07-30 22:51:30 nineties $

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

all: rlci rowl linker rlc1

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
VMOBJECTS = vm-main.o\
	    vm-eval.o\
	    vm-gc.o\
	    vm-load.o\
	    vm-prim-util.o\
	    vm-prim-io.o\
	    vm-prim-string.o\
	    vm-prim-vector.o\
	    vm-prim-cvector.o\
	    vm-prim-ivector.o

vm-compile.o      : stdlib.rlc config.rlc
vm-main.o         : stdlib.rlc vm-compile.rlc
vm-eval.o         : stdlib.rlc vm-compile.rlc vm-insn.rlc vm-prim-inc.rlc
vm-gc.o           : stdlib.rlc vm-compile.rlc
vm-load.o         : stdlib.rlc vm-compile.rlc
vm-prim-util.o    : stdlib.rlc vm-compile.rlc
vm-prim-io.o      : stdlib.rlc vm-compile.rlc
vm-prim-string.o  : stdlib.rlc vm-compile.rlc
vm-prim-vector.o  : stdlib.rlc vm-compile.rlc
vm-prim-cvector.o : stdlib.rlc vm-compile.rlc
vm-prim-ivector.o : stdlib.rlc vm-compile.rlc

rowl-assemble.rlc: stdlib.rlc config.rlc vm-insn.rlc
rowl-compile.rlc: stdlib.rlc rowl-assemble.rlc vm-prim-inc.rlc

rowl: $(VMOBJECTS)
	$(LD) $^ -o $@ $(VMLDFLAGS)

rlc1.rlo: rowl.rlc rlci rowl-compile.rlc
	./rlci $< > $@

linker: linker.rlc rlci rowl-compile.rlc
	./rlci $< > $@

rlc1: rowl linker rlc1.rlo
	./rowl linker rlc1.rlo -o rlc1

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
	rm -f *.o *.s *.rlo rlci rowl linker rlc1 core
