#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2010-12-30 20:13:13 nineties $

__define_function(f(x), Plus(f(Minus(x, 1)), f(Minus(x, 2))))
__define_function(f(0), 0)
__define_function(f(1), 1)
__define_function(f([]), 2)
__define_function(f([x]), x)
__define_function(f([x,y]), Plus(x,y))

print(f(20))
print(f([]))
print(f([100]))
print(f([100,200]))
