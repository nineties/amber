#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-01-12 22:34:36 nineties $

fib(n@Int): fib(n-2) + fib(n-1)
fib(1): 1
fib(2): 1

x: fib(20)
print(x)
#{
#    x: 1
#    print(x + 2)
#}
