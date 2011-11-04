#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-11-04 19:47:07 nineties $

prefix UnaryPlus "+" 5
prefix UnaryMinus "-" 5
prefix Not "not" 5
infixl Times "*" 6

+ y
{
    prefix Hoge "+" 5
    +y
}
+z
