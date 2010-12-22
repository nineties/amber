#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2010-12-22 22:14:52 nineties $

__define_function(fib, [x], Plus(fib(Minus(x, 1)), fib(Minus(x, 2))))
__define_function(fib, [0], 0)
__define_function(fib, [1], 1)
__define_function(f, ["hoge"], 1)
print(fib(20))
print(f("hoge"))
