#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-10-29 01:02:19 nineties $

f(): puts("Hello")
x: f
puts(\fullform, x)
x()
puts(\fullform, x->x+1)
puts((x->x+1)(2))
puts((p->p+1)(2,3))
