#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2011-10-14 03:57:56 nineties $

TOPDIR = ..
ROWL0DIR = $(TOPDIR)/rowl0
BINDIR = /usr/bin
LIBDIR = /usr/lib

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_start

RLC0 = $(ROWL0DIR)/rlc

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

all: rlvm linker disasm rowl1

startup.s : $(RLC0)
main.s    : $(RLC0) stddef.s code.s
stdlib.s  : $(RLC0) stddef.s
alloc.s   : $(RLC0) stddef.s
rowllib.s : $(RLC0) stddef.s
builtin.s : $(RLC0) stddef.s code.s
pprint.s  : $(RLC0) stddef.s code.s
lex.s     : $(RLC0) stddef.s token.s
parse.s   : $(RLC0) stddef.s token.s code.s
eval.s    : $(RLC0) stddef.s code.s

$(RLC0):
	cd $(ROWL0DIR); $(MAKE)

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

vm-compile.o      : rlci stdlib.rlc config.rlc
vm-main.o         : rlci stdlib.rlc vm-compile.rlc
vm-eval.o         : rlci stdlib.rlc vm-compile.rlc vm-insn.rlc vm-prim-inc.rlc
vm-gc.o           : rlci stdlib.rlc vm-compile.rlc
vm-load.o         : rlci stdlib.rlc config.rlc vm-compile.rlc
vm-prim-util.o    : rlci stdlib.rlc vm-compile.rlc
vm-prim-io.o      : rlci stdlib.rlc vm-compile.rlc
vm-prim-string.o  : rlci stdlib.rlc vm-compile.rlc
vm-prim-vector.o  : rlci stdlib.rlc vm-compile.rlc
vm-prim-tuple.o	  : rlci stdlib.rlc vm-compile.rlc
vm-prim-idtable.o : rlci stdlib.rlc vm-compile.rlc

RLC1OBJECTS = rowl1-main.rlo\
	      rowl1-util.rlo\
	      rowl1-lex.rlo\
	      rowl1-parse.rlo\
	      rowl1-node.rlo\
	      rowl1-symtable.rlo\
	      rowl1-interp.rlo\
	      rowl1-assemble.rlo\
	      rowl1-compile.rlo\
	      rowl1-matching.rlo\
	      rowl1-numeric.rlo\
	      rowl1-list.rlo\
	      rowl1-tuple.rlo\
	      rowl1-io.rlo

RLVMCOMPILER = rlci\
	       stdlib.rlc\
	       config.rlc\
	       vm-insn.rlc\
	       rlvm-compile.rlc\
	       rlvm-assemble.rlc\
	       vm-prim-inc.rlc

startup.rlo        : $(RLVMCOMPILER)
rowl1-main.rlo     : $(RLVMCOMPILER) rowl1-types.rlc rowl1-node.rlo rowl1-parse.rlo rowl1-interp.rlo
rowl1-util.rlo     : $(RLVMCOMPILER) rowl1-types.rlc
rowl1-lex.rlo      : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo
rowl1-parse.rlo    : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-lex.rlo rowl1-node.rlo
rowl1-node.rlo     : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-symtable.rlo
rowl1-symtable.rlo : $(RLVMCOMPILER) rowl1-types.rlc
rowl1-interp.rlo   : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-parse.rlo rowl1-symtable.rlo rowl1-assemble.rlo rowl1-compile.rlo rowl1-matching.rlo
rowl1-assemble.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-node.rlo
rowl1-compile.rlo  : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-symtable.rlo rowl1-assemble.rlo
rowl1-matching.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-assemble.rlo rowl1-compile.rlo
rowl1-numeric.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo
rowl1-list.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo rowl1-assemble.rlo
rowl1-tuple.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo rowl1-assemble.rlo
rowl1-io.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo

rlvm: $(VMOBJECTS)
	$(LD) $^ -o $@ $(VMLDFLAGS)

linker: linker.rlc $(RLVMCOMPILER)
	./rlci $< > $@

disasm: disasm.rlc $(RLVMCOMPILER)
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

install:
	cd $(TOPDIR); $(MAKE) install

install_binaries: rlvm rowl
	mkdir -p $(BINDIR)
	cp $^ $(BINDIR)

install_libraries: rowl1
	mkdir -p $(LIBDIR)/rowl/bin
	cp $^ $(LIBDIR)/rowl/bin
