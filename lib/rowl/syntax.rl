# Copyright (C) 2010 nineties
#
# $Id: syntax.rl 2011-01-10 23:26:46 nineties $

# Syntax definition of rowl language

DefineSyntax{RewriteExpr, InfixR{"=>", 20}}
DefineSyntax{Unquote, Prefix{"$", 3}}
DefineSyntax{Quote, Prefix{"!", 3}}
DefineSyntax{HeadP, InfixL{"@", 4}}
DefineSyntax{SymbolP, Prefix{"`", 2}}
DefineSyntax{DefineExpr, InfixR{":", 18}}

DefineFunction{Rewrite(x => y), !DefineFunction{Rewrite($x), $y}}

Apply{f@Symbol, args@List}: body => !DefineFunction{Apply{$f, $args}, $body}
x@Symbol: value => !DefineVariable{$x, $value}

`infixl(head@Symbol, repr@String, assoc@Int)  => !DefineSyntax{$head, InfixL{$repr, $assoc}}
`infixr(head@Symbol, repr@String, assoc@Int)  => !DefineSyntax{$head, InfixR{$repr, $assoc}}
`prefix(head@Symbol, repr@String, assoc@Int)  => !DefineSyntax{$head, Prefix{$repr, $assoc}}
`postfix(head@Symbol, repr@String, assoc@Int) => !DefineSyntax{$head, Postfix{$repr, $assoc}}
`constr(head@Symbol, repr@String)             => !DefineSyntax{$head, Constr{$repr}}
`command(head@Symbol, repr@String)            => !DefineSyntax{$head, Command{$repr}}

prefix(UnaryPlus,    "+",  5)
prefix(UnaryMinus,   "-",  5)
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
infixl(Else,         "else", 19)

UnaryPlus{x}  => !builtin_unaryplus($x)
UnaryMinus{x} => !builtin_unaryminus($x)
Plus{x, y}    => !builtin_plus($x, $y)
Minus{x, y}   => !builtin_minus($x, $y)
Times{x, y}   => !builtin_times($x, $y)
Divide{x, y}  => !builtin_divide($x, $y)
Mod{x, y}     => !builtin_mod($x, $y)
