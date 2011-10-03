#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-10-03 12:24:11 nineties $

fib(n): if (n < 3) 1 else fib(n-1) + fib(n-2)

print(fib(36))
