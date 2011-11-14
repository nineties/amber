#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-11-12 03:04:42 nineties $

i:0
s:0
while (i < 100) {
    s += i
    i += 1
}
puts(stdout, s)
puts(\(x -> y))


#f(): {
#    g(): puts("Hello")
#    g()
#    g(): puts("Hoge")
#}
#f()

fib(n): fib(n-1)+fib(n-2)
fib(0): 0
fib(1): 1
puts(fib(30))
{
    fib(0):1
    fib(1):1
    puts(fib(30))
}
puts(fib(30))
