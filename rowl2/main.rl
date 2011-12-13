#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-12-14 00:24:10 nineties $

module M {
    x: 1
    f(): {
        puts("Hello")
    }
}
M::f()
puts(M::x)

module M::N {
}
