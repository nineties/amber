#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-01-10 16:16:14 nineties $

fib(n@Int): fib(n-2) + fib(n-1)
fib(1): 1
fib(2): 1

print(fib(20))
print('\n')

if (0) {
    print(fib(20))
}

while 1 {
    print("hello\n")
}
