#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-10-22 06:56:33 nineties $

#test of lambda
{
    puts(obj): puts(\fullform, obj)
    (\puts)(obj) => `puts(\fullform, !obj)
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

#fib(n): fib(n-1) + fib(n-2)
#fib(0): 0
#fib(1): 1

#puts(fib(36))
