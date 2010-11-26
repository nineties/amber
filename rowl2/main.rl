#!../rowl1/rowl

# rowl - generation 2
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2010-11-26 21:23:53 nineties $
#

fib(n!Int): fib(n-1) + fib(n-2)
fib(0): 0
fib(1): 1

print_int(fib(36))
