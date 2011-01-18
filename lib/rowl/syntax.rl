# Copyright (C) 2010 nineties
#
# $Id: syntax.rl 2011-01-19 01:58:37 nineties $

# Syntax definition of rowl language

DefineSyntax{RewriteExpr, InfixR{"=>", 20}}
DefineSyntax{Unquote, Prefix{"$", 3}}
DefineSyntax{Quote, Prefix{"!", 3}}
DefineSyntax{HeadP, InfixL{"@", 4}}
DefineSyntax{SymbolP, Prefix{"`", 2}}
DefineSyntax{DefineExpr, InfixR{":", 18}}

DefineFunction{Rewrite(x => y), !DefineFunction{Rewrite($x), !$y}}

Apply{f@Symbol, args@List}: body => DefineFunction{Apply{$f, $args}, $body}
x@Symbol: value => DefineVariable{$x, $value}

`infixl(head@Symbol, repr@String, assoc@Int)  => DefineSyntax{$head, InfixL{$repr, $assoc}}
`infixr(head@Symbol, repr@String, assoc@Int)  => DefineSyntax{$head, InfixR{$repr, $assoc}}
`prefix(head@Symbol, repr@String, assoc@Int)  => DefineSyntax{$head, Prefix{$repr, $assoc}}
`postfix(head@Symbol, repr@String, assoc@Int) => DefineSyntax{$head, Postfix{$repr, $assoc}}
`constr(head@Symbol, repr@String)             => DefineSyntax{$head, Constr{$repr}}
`command(head@Symbol, repr@String)            => DefineSyntax{$head, Command{$repr}}

prefix(UnaryPlus,    "+",  5)
prefix(UnaryMinus,   "-",  5)
prefix(Not,          "not",5)
infixl(Times,        "*",  6)
infixl(Divide,       "/",  6)
infixl(Mod,          "%",  6)
infixl(Plus,         "+",  7)
infixl(Minus,        "-",  7)
infixl(Less,         "<",  9)
infixl(Greater,      ">",  9)
infixl(LessThan,     "<=", 9)
infixl(GreaterThan,  ">=", 9)
infixl(Equal,        "==", 10)
infixl(NotEqual,     "!=", 10)
infixl(And,          "&",  11)
infixl(Xor,          "^",  12)
infixl(Or,           "|",  13)
infixl(LogicalAnd,   "and", 14)
infixl(LogicalOr,    "or", 15)
infixr(Assign,       "=",  17)
infixr(PlusAssign,   "+=", 17)
infixr(MinusAssign,  "-=", 17)
infixr(TimesAssign,  "*=", 17)
infixr(DivideAssign, "/=", 17)
infixr(ModAssign,    "%=", 17)
constr(If,           "if")
constr(While,        "while")
constr(For,          "for")
command(Return,      "return")
infixl(IfElse,       "else", 19)

+x     => builtin_unaryplus($x)
-x     => builtin_unaryminus($x)
not x  => builtin_not($x)
x + y  => builtin_plus($x, $y)
x - y  => builtin_minus($x, $y)
x * y  => builtin_times($x, $y)
x / y  => builtin_divide($x, $y)
x % y  => builtin_mod($x, $y)
x < y  => builtin_less($x, $y)
x > y  => $y < $x
x <= y => not($y < $x)
x >= y => not($x < $y)
x == y => builtin_equal($x, $y)
