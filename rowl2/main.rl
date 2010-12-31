#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2010-12-31 13:02:27 nineties $


__define_function{Apply{f, List{x}}, x}
print(f(1))
__define_function{Apply{f, [x]}, x}
print(f(2))
__define_function{f(x), x}
print(f(3))
