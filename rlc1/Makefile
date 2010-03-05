#
# rowl - 
# Copyright (C) 2010 nineties
#

# $Id: Makefile 2010-01-27 21:51:00 nineties $

AS = as
ASFLAGS =
LD = ld
LDFLAGS = --nostdlib --entry=_start

RLC0 = ../rlc0/rlc
SOURCES    = startup.rl main.rl stddef.rl stdlib.rl alloc.rl rowllib.rl \
			 token.rl lex.rl code.rl node.rl parse.rl type.rl typing.rl \
			 rewrite.rl eval.rl codegen.rl pprint.rl
ASMSOURCES = $(patsubst %.rl,%.s,$(SOURCES))
OBJECTS    = $(patsubst %.rl,%.o,$(SOURCES))

all: 
	cd ..; $(MAKE)

$(ASMSOURCES): $(RLC0)
alloc.s: stddef.s
main.s: stddef.s code.s
rowllib.s: stddef.s
stdlib.s: stddef.s
lex.s: stddef.s code.s token.s
node.s: stddef.s code.s
parse.s: stddef.s code.s token.s
type.s: stddef.s code.s
typing.s: stddef.s code.s
rewrite.s: stddef.s code.s
eval.s: stddef.s code.s
codegen.s: stddef.s code.s
pprint.s: stddef.s code.s

rlc: $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

.SUFFIXES: .rl

.rl.s:
	$(RLC0) < $< > $@

.s.o:
	$(AS) $< -o $@ $(ASFLAGS)

.PHONY: clean
clean:
	rm -f *.o *.s rlc core
