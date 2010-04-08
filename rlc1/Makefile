#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-04-09 02:54:12 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_start

RLC0 = ../rlc0/rlc
SOURCES = startup.rl main.rl stddef.rl stdlib.rl alloc.rl rowllib.rl \
	  token.rl lex.rl code.rl node.rl parse.rl type.rl typing.rl \
	  closure.rl mangle.rl tcodegen.rl proc.rl instruction.rl deadcode.rl \
	  liveness.rl regalloc.rl asmgen.rl pprint.rl headergen.rl

ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

alloc.s       : $(RLC0) stddef.s
main.s        : $(RLC0) stddef.s code.s
rowllib.s     : $(RLC0) stddef.s
stdlib.s      : $(RLC0) stddef.s
lex.s         : $(RLC0) stddef.s code.s token.s
node.s        : $(RLC0) stddef.s code.s
parse.s       : $(RLC0) stddef.s code.s token.s
type.s        : $(RLC0) stddef.s code.s
typing.s      : $(RLC0) stddef.s code.s
closure.s     : $(RLC0) stddef.s code.s
mangle.s      : $(RLC0) code.s
tcodegen.s    : $(RLC0) stddef.s code.s
instruction.s : $(RLC0) stddef.s code.s
proc.s        : $(RLC0) stddef.s code.s
deadcode.s    : $(RLC0) stddef.s code.s
liveness.s    : $(RLC0) stddef.s code.s
regalloc.s    : $(RLC0) stddef.s code.s
asmgen.s      : $(RLC0) stddef.s code.s
pprint.s      : $(RLC0) stddef.s code.s
headergen.s   : $(RLC0) stddef.s code.s

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

.SUFFIXES:
.SUFFIXES: .o .s .rl

.rl.s:
	$(RLC0) < $< > $@

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.PHONY: clean
clean:
	rm -f *.o *.s rlc core
