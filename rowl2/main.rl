#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-12-31 10:29:58 nineties $

#include "rowl.rl"

#print(stdout, \(x -> x))
#print(stdout, '\n')
#print(stdout, x->x)
#print(stdout, (f->f("Hello\n"))(x->print(stdout, x)))
#(x->x|x@Int->2)(1)
print(stdout, (1 -> "Hello"|2 -> "World")(2))
