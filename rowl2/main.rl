#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2010-12-31 00:36:42 nineties $

#__define_function(f(x), Plus(f(Minus(x, 1)), f(Minus(x, 2))))
__define_function(f(x), x)
__define_function(f(0), 0)
__define_function(f(1), 1)
__define_function(f([]), 2)
__define_function(f([x]), x)
__define_function(f([x,y]), Plus(x,y))
__define_function(f([0]), 1)
__define_function(f("hello"), "hello")
__define_function(f(["hello"]), "moge")

print(f(0))
print(f(1))
print(f(2))
print(f(3))
print(f(4))
print(f(5))
print(f(6))
print(f(7))
print(f(8))
print(f(20))
print(f([]))
print(f([100]))
print(f([100,200]))
print(f([3]))
print(f([0]))
print(f("hello"))
print(f(["Hello"]))
print(f(["hello"]))
