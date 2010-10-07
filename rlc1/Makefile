#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-10-07 15:56:54 nineties $

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

all: rlci rowl linker disasm rlc1

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
	    vm-prim-tuple.o\
	    vm-prim-idtable.o

vm-compile.o      : stdlib.rlc config.rlc
vm-main.o         : stdlib.rlc vm-compile.rlc
vm-eval.o         : stdlib.rlc vm-compile.rlc vm-insn.rlc vm-prim-inc.rlc
vm-gc.o           : stdlib.rlc vm-compile.rlc
vm-load.o         : stdlib.rlc config.rlc vm-compile.rlc
vm-prim-util.o    : stdlib.rlc vm-compile.rlc
vm-prim-io.o      : stdlib.rlc vm-compile.rlc
vm-prim-string.o  : stdlib.rlc vm-compile.rlc
vm-prim-vector.o  : stdlib.rlc vm-compile.rlc
vm-prim-tuple.o	  : stdlib.rlc vm-compile.rlc
vm-prim-idtable.o : stdlib.rlc vm-compile.rlc

RLC1OBJECTS = rlc1-main.rlo rlc1-lex.rlo
ROWLCOMPILER = rlci rowl-compile.rlc rowl-assemble.rlc vm-prim-inc.rlc

startup.rlo   : $(ROWLCOMPILER)
rlc1-main.rlo : $(ROWLCOMPILER)
rlc1-lex.rlo  : $(ROWLCOMPILER)

rowl: $(VMOBJECTS)
	$(LD) $^ -o $@ $(VMLDFLAGS)

linker: linker.rlc $(ROWLCOMPILER)
	./rlci $< > $@

disasm: disasm.rlc $(ROWLCOMPILER)
	./rlci $< > $@

rlc1: rowl linker $(RLC1OBJECTS) startup.rlo
	./rowl linker $(RLC1OBJECTS) -o rlc1

.SUFFIXES:
.SUFFIXES: .o .s .rl .rlc .rlo

.rl.s:
	$(RLC0) < $< > $@

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.rlc.s:
	./rlci $< > $@

.rlc.rlo:
	./rlci $< > $@

.PHONY: clean
clean:
	rm -f *.o *.s *.rlo rlci rowl linker disasm rlc1 dfuntest core
