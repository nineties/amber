#
# amber - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2013-03-16 13:09:52 nineties $

TOPDIR = ..
ROWL0DIR = $(TOPDIR)/rowl0
BINDIR = /usr/bin
LIBDIR = /usr/lib

AS = as
ASFLAGS = --32
LD = ld
LDFLAGS = --nostdlib -m elf_i386 --entry=_start

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
OBJECTS	= $(patsubst %.rl,%.o,$(SOURCES))

all: rlvm linker disasm rowl1

startup.s : $(RLC0)
main.s	: $(RLC0) stddef.s code.s
stdlib.s  : $(RLC0) stddef.s
alloc.s   : $(RLC0) stddef.s
rowllib.s : $(RLC0) stddef.s
builtin.s : $(RLC0) stddef.s code.s
pprint.s  : $(RLC0) stddef.s code.s
lex.s	 : $(RLC0) stddef.s token.s
parse.s   : $(RLC0) stddef.s token.s code.s
eval.s	: $(RLC0) stddef.s code.s

$(RLC0):
	cd $(ROWL0DIR); $(MAKE)

rlci: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)


VMLDFLAGS = --nostdlib -m elf_i386 --entry=_start
VMOBJECTS = vm-main.o\
		vm-eval.o\
		vm-gc.o\
		vm-load.o\
		vm-prim-util.o\
		vm-prim-sys.o\
		vm-prim-io.o\
		vm-prim-string.o\
		vm-prim-vector.o\
		vm-prim-tuple.o\
		vm-prim-idtable.o\
		vm-prim-wrtable.o\
		vm-prim-random.o

vm-compile.o      : rlci stdlib.rlc config.rlc
vm-main.o         : rlci stdlib.rlc vm-compile.rlc
vm-eval.o         : rlci stdlib.rlc vm-compile.rlc vm-insn.rlc vm-prim-inc.rlc
vm-gc.o           : rlci stdlib.rlc vm-compile.rlc
vm-load.o         : rlci stdlib.rlc config.rlc vm-compile.rlc
vm-prim-util.o    : rlci stdlib.rlc vm-compile.rlc
vm-prim-sys.o     : rlci stdlib.rlc vm-compile.rlc
vm-prim-io.o      : rlci stdlib.rlc vm-compile.rlc
vm-prim-string.o  : rlci stdlib.rlc vm-compile.rlc
vm-prim-vector.o  : rlci stdlib.rlc vm-compile.rlc
vm-prim-tuple.o   : rlci stdlib.rlc vm-compile.rlc
vm-prim-idtable.o : rlci stdlib.rlc vm-compile.rlc
vm-prim-wrtable.o : rlci stdlib.rlc vm-compile.rlc
vm-prim-random.o  : rlci stdlib.rlc vm-compile.rlc

RLC1OBJECTS = rowl1-main.rlo\
		  rowl1-util.rlo\
		  rowl1-symtable.rlo\
		  rowl1-node.rlo\
		  rowl1-packrat.rlo\
		  rowl1-module.rlo\
		  rowl1-interp.rlo\
		  rowl1-assemble.rlo\
		  rowl1-compile.rlo\
		  rowl1-matching.rlo\
		  rowl1-error.rlo\
		  rowl1-base.rlo\
		  rowl1-symbol.rlo\
		  rowl1-numeric.rlo\
		  rowl1-bigint.rlo\
		  rowl1-float.rlo\
		  rowl1-random.rlo\
		  rowl1-math.rlo\
		  rowl1-string.rlo\
		  rowl1-list.rlo\
		  rowl1-tuple.rlo\
		  rowl1-array.rlo\
		  rowl1-table.rlo\
		  rowl1-oop.rlo\
		  rowl1-function.rlo\
		  rowl1-io.rlo\
		  rowl1-pprint.rlo\
		  rowl1-gc.rlo

RLVMCOMPILER = rlci\
		   stdlib.rlc\
		   config.rlc\
		   vm-insn.rlc\
		   rlvm-compile.rlc\
		   rlvm-assemble.rlc\
		   vm-prim-inc.rlc

startup.rlo		: $(RLVMCOMPILER)
rowl1-main.rlo	 : $(RLVMCOMPILER) rowl1-types.rlc rowl1-node.rlo rowl1-interp.rlo rowl1-util.rlo
rowl1-util.rlo	 : $(RLVMCOMPILER) rowl1-types.rlc
rowl1-packrat.rlo	: $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-assemble.rlo rowl1-compile.rlo rowl1-module.rlo rowl1-error.rlo
rowl1-node.rlo	 : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-symtable.rlo
rowl1-symtable.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlc
rowl1-module.rlo   : $(RLVMCOMPILER) rowl1-types.rlc rowl1-node.rlo rowl1-symtable.rlo rowl1-error.rlo
rowl1-interp.rlo   : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-packrat.rlo rowl1-symtable.rlo rowl1-assemble.rlo rowl1-compile.rlo rowl1-matching.rlo rowl1-error.rlo rowl1-pprint.rlo
rowl1-assemble.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-node.rlo rowl1-util.rlo
rowl1-compile.rlo  : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-symtable.rlo rowl1-module.rlo rowl1-assemble.rlo rowl1-error.rlo
rowl1-matching.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-assemble.rlo rowl1-compile.rlo rowl1-error.rlo
rowl1-error.rlo: $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo
rowl1-base.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo rowl1-error.rlo
rowl1-symbol.rlo: $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo
rowl1-numeric.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo rowl1-error.rlo rowl1-module.rlo
rowl1-bigint.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo
rowl1-float.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-assemble.rlo rowl1-error.rlo
rowl1-random.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-assemble.rlo rowl1-error.rlo rowl1-bigint.rlo rowl1-float.rlo
rowl1-math.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-float.rlo rowl1-numeric.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-assemble.rlo rowl1-error.rlo
rowl1-string.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-error.rlo
rowl1-list.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-assemble.rlo rowl1-error.rlo
rowl1-tuple.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-assemble.rlo rowl1-error.rlo
rowl1-array.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-assemble.rlo rowl1-error.rlo
rowl1-table.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-error.rlo rowl1-pprint.rlo
rowl1-function.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-error.rlo
rowl1-oop.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-error.rlo
rowl1-io.rlo : $(RLVMCOMPILER) rowl1-types.rlc rowl1-util.rlo rowl1-node.rlo rowl1-module.rlo rowl1-compile.rlo rowl1-error.rlo rowl1-pprint.rlo rowl1-bigint.rlo
rowl1-pprint.rlo : $(RLVMCOMPILER) rowl1-types.rlo rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo
rowl1-gc.rlo : $(RLVMCOMPILER) rowl1-types.rlo rowl1-util.rlo rowl1-node.rlo rowl1-compile.rlo rowl1-module.rlo rowl1-symbol.rlo

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

install_binaries: amber
	mkdir -p $(BINDIR)
	cp $^ $(BINDIR)

install_libraries: rowl1 rlvm
	mkdir -p $(LIBDIR)/amber/bin
	cp $^ $(LIBDIR)/amber/bin
