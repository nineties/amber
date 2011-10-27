#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-10-28 02:24:21 nineties $

# test of lambda
{
    puts(obj): puts(\fullform, obj)
    puts(\(x -> x + 1))
    p: x -> x + 1
    puts(p)
    p = (x,y) -> x + y
    puts(p)
    puts(\((x,y)->x+y)(1,2))
    puts(\map(x->x+1,ary))
    puts(\(x -> y -> x + y))
    puts(x->x)
    puts(\f(x))
    puts(\f(x,y,z))
}
f(): { puts("Hello") }
x: f
puts(\fullform, x)
x()
puts(\fullform, x->x+1)
puts((x->x+1)(2))
