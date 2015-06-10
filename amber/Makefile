#
# amber - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2015-06-10 18:51:57 nineties $

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

all: rlvm linker disasm amberi

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

AMBOBJECTS = amber-main.rlo\
			  amber-util.rlo\
			  amber-interp.rlo\
			  amber-node.rlo\
			  amber-error.rlo\
			  amber-object.rlo\
			  amber-symtable.rlo\
			  amber-assemble.rlo\
			  amber-compile.rlo\
			  amber-matching.rlo\
			  amber-packrat.rlo\
			  amber-base.rlo\
			  amber-function.rlo\
			  amber-symbol.rlo\
			  amber-numeric.rlo\
			  amber-float.rlo\
			  amber-math.rlo\
			  amber-random.rlo\
			  amber-string.rlo\
			  amber-list.rlo\
			  amber-tuple.rlo\
			  amber-array.rlo\
			  amber-table.rlo\
			  amber-io.rlo\
			  amber-pprint.rlo\
			  amber-encoding.rlo\
			  amber-sys.rlo\
			  amber-gc.rlo

RLVMCOMPILER = rlci\
		   stdlib.rlc\
		   config.rlc\
		   vm-insn.rlc\
		   rlvm-compile.rlc\
		   rlvm-assemble.rlc\
		   vm-prim-inc.rlc

startup.rlo		: $(RLVMCOMPILER)
amber-main.rlo	 : $(RLVMCOMPILER) amber-types.rlc amber-interp.rlo
amber-util.rlo	 : $(RLVMCOMPILER) amber-types.rlc
amber-interp.rlo   : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-error.rlo amber-object.rlo amber-symtable.rlo amber-assemble.rlo amber-compile.rlo amber-packrat.rlo amber-pprint.rlo amber-math.rlo amber-tuple.rlo amber-array.rlo
amber-node.rlo	 : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo
amber-error.rlo: $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo
amber-object.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-compile.rlo amber-error.rlo
amber-symtable.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlc
amber-assemble.rlo : $(RLVMCOMPILER) amber-types.rlc amber-node.rlo amber-util.rlo
amber-compile.rlo  : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-error.rlo amber-symtable.rlo amber-assemble.rlo
amber-matching.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-assemble.rlo amber-compile.rlo amber-error.rlo
amber-packrat.rlo	: $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-assemble.rlo amber-compile.rlo amber-error.rlo
amber-base.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-error.rlo
amber-function.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-error.rlo
amber-symbol.rlo: $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo
amber-numeric.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-compile.rlo
amber-float.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-assemble.rlo amber-error.rlo amber-base.rlo amber-numeric.rlo
amber-string.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-error.rlo
amber-list.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-assemble.rlo amber-error.rlo amber-table.rlo
amber-tuple.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-assemble.rlo amber-error.rlo
amber-array.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-assemble.rlo amber-error.rlo amber-tuple.rlo amber-table.rlo
amber-table.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-error.rlo amber-pprint.rlo
amber-io.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-error.rlo amber-pprint.rlo amber-numeric.rlo amber-string.rlo
amber-pprint.rlo : $(RLVMCOMPILER) amber-types.rlo amber-util.rlo amber-node.rlo amber-compile.rlo amber-string.rlo
amber-random.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-assemble.rlo amber-error.rlo amber-numeric.rlo amber-float.rlo
amber-math.rlo : $(RLVMCOMPILER) amber-types.rlc amber-util.rlo amber-node.rlo amber-object.rlo amber-float.rlo amber-compile.rlo amber-assemble.rlo amber-error.rlo
amber-gc.rlo : $(RLVMCOMPILER) amber-types.rlo amber-util.rlo amber-node.rlo amber-compile.rlo amber-symbol.rlo
amber-encoding.rlo : $(RLVMCOMPILER) amber-types.rlo amber-util.rlo amber-node.rlo amber-error.rlo amber-compile.rlo
amber-sys.rlo : $(RLVMCOMPILER) amber-types.rlo amber-util.rlo amber-node.rlo amber-object.rlo amber-compile.rlo amber-error.rlo amber-numeric.rlo

rlvm: $(VMOBJECTS)
	$(LD) $^ -o $@ $(VMLDFLAGS)

linker: linker.rlc $(RLVMCOMPILER)
	./rlci $< > $@

disasm: disasm.rlc $(RLVMCOMPILER)
	./rlci $< > $@

amberi: rlvm linker $(AMBOBJECTS) startup.rlo
	./rlvm linker $(AMBOBJECTS) -o $@

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
	rm -f *.o *.s *.rlo rlci rlvm linker disasm amberi core

install:
	cd $(TOPDIR); $(MAKE) install

install_binaries: amber
	mkdir -p $(BINDIR)
	cp $^ $(BINDIR)

install_libraries: amberi rlvm
	mkdir -p $(LIBDIR)/amber/bin
	cp $^ $(LIBDIR)/amber/bin
