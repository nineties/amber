#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-10-28 14:17:05 nineties $

f(): { puts("Hello") }
x: f
puts(\fullform, x)
x()
puts(\fullform, x->x+1)
puts((x->x+1)(2))
puts((x->x+1)(2,3))
