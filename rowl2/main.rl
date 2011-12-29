#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-12-29 00:43:12 nineties $

#include "rowl.rl"

#fib(n): fib(n-1) + fib(n-2)
#f(): {
#	fib(0): 0
#	fib(1): 1
#	fib(30) # -> Apply{fib, [30]}
#}

print(stdout, \(x -> x))
print(stdout, '\n')
