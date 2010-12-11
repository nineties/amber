#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-12-10 16:59:28 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_start

RLC0 = ../rowl0/rlc
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

all: rlci rlvm linker disasm rowl1

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

RLC1OBJECTS = rowl1-main.rlo\
	      rowl1-util.rlo\
	      rowl1-lex.rlo\
	      rowl1-stdlib.rlo\
	      rowl1-parse.rlo\
	      rowl1-node.rlo\
	      rowl1-symtable.rlo\
	      rowl1-assemble.rlo\
	      rowl1-compile.rlo\
	      rowl1-matching.rlo\
	      rowl1-interp.rlo

RLVMCOMPILER = rlci\
	       stdlib.rlc\
	       config.rlc\
	       vm-insn.rlc\
	       rlvm-compile.rlc\
	       rlvm-assemble.rlc\
	       vm-prim-inc.rlc

startup.rlo        : $(RLVMCOMPILER)
rowl1-main.rlo     : $(RLVMCOMPILER) rowl1-types.rlc rowl1-node.rlo rowl1-lex.rlo rowl1-stdlib.rlo rowl1-interp.rlo
rowl1-util.rlo     : $(RLVMCOMPILER) rowl1-types.rlc
rowl1-lex.rlo      : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo
rowl1-parse.rlo    : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-lex.rlo rowl1-node.rlo
rowl1-node.rlo     : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo
rowl1-stdlib.rlo   : $(RLVMCOMPILER) rowl1-types.rlc rowl1-node.rlo rowl1-interp.rlo rowl1-compile.rlo
rowl1-symtable.rlo : $(RLVMCOMPILER) rowl1-types.rlc
rowl1-interp.rlo   : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-parse.rlo rowl1-symtable.rlo rowl1-assemble.rlo rowl1-compile.rlo rowl1-matching.rlo
rowl1-assemble.rlo : $(RLVMCOMPILER)
rowl1-compile.rlo  : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-symtable.rlo rowl1-assemble.rlo
rowl1-matching.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-assemble.rlo rowl1-compile.rlo

rlvm: $(VMOBJECTS)
	$(LD) $^ -o $@ $(VMLDFLAGS)

linker: linker.rlc rlvm $(RLVMCOMPILER)
	./rlci $< > $@

disasm: disasm.rlc rlvm $(RLVMCOMPILER)
	./rlci $< > $@

rowl1: rlvm linker $(RLC1OBJECTS) startup.rlo
	./rlvm linker $(RLC1OBJECTS) -o rowl1

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
	rm -f *.o *.s *.rlo rlci rlvm linker disasm rowl1 core
