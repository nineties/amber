# Copyright (C) 2010 nineties
#
# $Id: syntax.rl 2011-10-11 11:47:16 nineties $

# Syntax definition of rowl language

DefineSyntax{Rewrite, InfixR{"=>", 20}}
DefineSyntax{Unquote, Prefix{"$", 3}}
DefineSyntax{Quote, Prefix{"`", 3}}
DefineSyntax{HeadP, InfixL{"@", 4}}
DefineSyntax{Define, InfixR{":", 19}}

DefineFunction{Compile(_, _, x => y), Eval{AppendFunction{Compile(out, env, $x), Compile(out, env, `$y)}}}

Apply{f@Symbol, args@List}: body => DefineFunction{Apply{$f, $args}, $body}
x@Symbol: value => DefineVariable{$x, $value}

(`infixl)(head@Symbol, repr@String, assoc@Int)  => DefineSyntax{$head, InfixL{$repr, $assoc}}
(`infixr)(head@Symbol, repr@String, assoc@Int)  => DefineSyntax{$head, InfixR{$repr, $assoc}}
(`prefix)(head@Symbol, repr@String, assoc@Int)  => DefineSyntax{$head, Prefix{$repr, $assoc}}
(`postfix)(head@Symbol, repr@String, assoc@Int) => DefineSyntax{$head, Postfix{$repr, $assoc}}
(`constr)(head@Symbol, repr@String)             => DefineSyntax{$head, Constr{$repr}}
(`command)(head@Symbol, repr@String)            => DefineSyntax{$head, Command{$repr}}

prefix(UnaryPlus,    "+",  5)
prefix(UnaryMinus,   "-",  5)
prefix(Not,          "not",5)
infixl(Times,        "*",  6)
infixl(Divide,       "/",  6)
infixl(Mod,          "%",  6)
infixl(Plus,         "+",  7)
infixl(Minus,        "-",  7)
infixl(LessThan,     "<",  9)
infixl(GreaterThan,  ">",  9)
infixl(LessEqual,    "<=", 9)
infixl(GreaterEqual, ">=", 9)
infixl(Equal,        "==", 10)
infixl(NotEqual,     "!=", 10)
infixl(And,          "&",  11)
infixl(Xor,          "^",  12)
infixl(Or,           "|",  13)
infixl(LogicalAnd,   "&&", 14)
infixl(LogicalOr,    "||", 15)
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
infixl(Else,         "else", 18)

true: `true
false: `false

command(Import, "import")
infixl(DoubleColon, "::", 2)

+x     => UnaryPlus($x)
-x     => UnaryMinus($x)
not x  => Not($x)
x * y  => Times($x, $y)
x / y  => Divide($x, $y)
x % y  => Mod($x, $y)
x + y  => Plus($x, $y)
x - y  => Minus($x, $y)
x < y  => LessThan($x, $y)
x > y  => GreaterThan($x, $y)
x >= y => GreaterEqual($x, $y)
x <= y => LessEqual($x, $y)
x += y => $x = $x + $y
x -= y => $x = $x - $y
x *= y => $x = $x * $y
x /= y => $x = $x / $y
x %= y => $x = $x % $y
x[y]   => Subscript($x, $y)
