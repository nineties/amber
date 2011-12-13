#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-12-14 00:44:25 nineties $

module X {
    constr Hoge "hoge"
}

module M {
    import X, Y
}
