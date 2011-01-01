#!/usr/bin/rowl

# rowl - 2nd generation
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2011-01-01 13:19:04 nineties $


DefineSyntax{RewriteExpr, InfixR{"=>", 17}}
DefineSyntax{Unquote, Prefix{"$", 3}}
DefineSyntax{Quote, Prefix{"!", 3}}
DefineSyntax{DefineExpr, InfixR{":", 16}}

DefineFunction{Rewrite(x => y), !DefineFunction{Rewrite($x), !$y}}

Apply{f, args}: body => DefineFunction{Apply{$f, $args}, $body}

f(x): 2
print(f(3))
[1,2,3] => [1,2,3,4]
print([1,2,3])
