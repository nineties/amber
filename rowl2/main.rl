#!../rowl1/rowl

# rowl - generation 2
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2010-12-11 19:17:48 nineties $

define_operator("+", Plus, InfixL, 8)

print("hello world\n")
print(1 + 3)
print(1 + "hoge")
