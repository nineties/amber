#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-01-04 00:48:05 nineties $

fib(n@Int): fib(n-2) + fib(n-1)
fib(1): 1
fib(2): 1

print(fib(20))
print('\n')
