#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-03-25 01:14:53 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_start

RLC0 = ../rlc0/rlc
SOURCES    = startup.rl main.rl stddef.rl stdlib.rl alloc.rl rowllib.rl \
			 token.rl lex.rl code.rl node.rl parse.rl type.rl typing.rl \
			 mangle.rl tcodegen.rl proc.rl asmgen.rl pprint.rl
ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

alloc.o    : $(RLC0) stddef.s
main.o     : $(RLC0) stddef.s code.s
rowllib.o  : $(RLC0) stddef.s
stdlib.o   : $(RLC0) stddef.s
lex.o      : $(RLC0) stddef.s code.s token.s
node.o     : $(RLC0) stddef.s code.s
parse.o    : $(RLC0) stddef.s code.s token.s
type.o     : $(RLC0) stddef.s code.s
typing.o   : $(RLC0) stddef.s code.s
mangle.o   : $(RLC0) code.s
tcodegen.o : $(RLC0) stddef.s code.s
proc.o     : $(RLC0) stddef.s code.s
asmgen.o   : $(RLC0) stddef.s code.s
pprint.o   : $(RLC0) stddef.s code.s

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
