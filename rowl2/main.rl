#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-04-08 11:49:24 nineties $

sum: 0
n: 1
while (n < 1000) {
    if (n%3 == 0 or n%5 == 0) { sum += n }
    n += 1
}
print(sum)
