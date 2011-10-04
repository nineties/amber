#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-10-04 17:02:48 nineties $

fib(n): {
    a0:0
    a1:1
    while (n > 1) {
        t: a0
        a0 = a1
        a1 = t + a1
        n -= 1
    }
    return a1
}

puts(fib(36))
