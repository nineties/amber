# Copyright (C) 2010 nineties
#
# $Id: syntax.rl 2011-12-13 21:38:34 nineties $

# Syntax definition of rowl language

infixl Qualified "::" 2
prefix Unquote "!" 4
prefix Quote "\\" 4
prefix QuasiQuote "`" 4
infixl HeadP "@" 5
infixr Define ":" 19
infixr Rewrite "=>" 20

DefineFunction{
    Rewrite(x => y),
    `DefineFunction{
        Rewrite(!x),
        Rewrite(!y)
    }
}

Apply{f@Symbol, args@List}: body => `DefineFunction{Apply{!f, !args}, !body}
x@Symbol: value => `DefineVariable{!x, !value}

prefix UnaryPlus    "+"  6
prefix UnaryMinus   "-"  6
prefix Not          "not"6
infixl Times        "*"  7
infixl Divide       "/"  7
infixl Mod          "%"  7
infixl Plus         "+"  8
infixl Minus        "-"  8
infixl LessThan     "<"  10 
infixl GreaterThan  ">"  10
infixl LessEqual    "<=" 10
infixl GreaterEqual ">=" 10
infixl Equal        "==" 11
infixl NotEqual     "!=" 11
infixl LogicalAnd   "&&" 12
infixl LogicalOr    "||" 13
infixr Lambda       "->" 14
infixr Assign       "="  17
infixr PlusAssign   "+=" 17
infixr MinusAssign  "-=" 17
infixr TimesAssign  "*=" 17
infixr DivideAssign "/=" 17
infixr ModAssign    "%=" 17
constr If           "if"
constr While        "while"
constr For          "for"
command Return      "return"
infixl Else         "else" 18

true: \true
false: \false

command Import "import"
infixl  Dot "." 2

+x     => `UnaryPlus(!x)
-x     => `UnaryMinus(!x)
not x  => `Not(!x)
x * y  => `Times(!x, !y)
x / y  => `Divide(!x, !y)
x % y  => `Mod(!x, !y)
x + y  => `Plus(!x, !y)
x - y  => `Minus(!x, !y)
x < y  => `LessThan(!x, !y)
x > y  => `GreaterThan(!x, !y)
x >= y => `GreaterEqual(!x, !y)
x <= y => `LessEqual(!x, !y)
x += y => `(!x = !x + !y)
x -= y => `(!x = !x - !y)
x *= y => `(!x = !x * !y)
x /= y => `(!x = !x / !y)
x %= y => `(!x = !x % !y)
x[y]   => `Subscript(!x, !y)
