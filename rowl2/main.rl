#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-12-28 11:06:39 nineties $

#include "rowl.rl"

#fib(n): fib(n-1) + fib(n-2)
#f(): {
#	fib(0): 0
#	fib(1): 1
#	fib(30) # -> Apply{fib, [30]}
#}

print(stdout, "Hello World\n")
print(stdout, \fullform, "Hello World\n")
