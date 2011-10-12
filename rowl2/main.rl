#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-10-12 21:13:26 nineties $

x: [1,2,3,4]
puts(x)
puts(x[0])
puts(x[1])
puts(x[2])
puts(x[3])

puts(length(x))
puts(cons("Hello World", x))
puts(x)
puts(reverse(cons("Hello World", x)))
