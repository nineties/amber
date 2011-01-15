#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-01-15 23:27:38 nineties $

fib(n@Int): fib(n-2) + fib(n-1)
fib(1): 1
fib(2): 1

x: fib(20)
print(x)

{
    a: 5
    print(a + 3)
    a = 1
    print(a)
    x = 10
    print(x)
}
