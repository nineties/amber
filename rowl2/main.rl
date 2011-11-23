#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-11-23 20:46:53 nineties $

puts("Hello World")

fib(n): fib(n-1)+fib(n-2)
fib(0): 0
fib(1): 1
puts(fib(30))
{
    fib(0):1
    puts(fib(30))
}
puts(fib(30))
