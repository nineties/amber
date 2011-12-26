# Copyright (C) 2010 nineties
#
# $Id: syntax.rl 2011-12-14 12:23:21 nineties $

# Syntax definition of rowl language

module core {

command Include "include"
command Import "import"

infixr Qualified "::" 1
prefix Unquote "!" 3
prefix Quote "\\" 3
prefix QuasiQuote "`" 3
infixl HeadP "@" 4
infixr Define ":" 19
infixr Rewrite "=>" 20

#DefineFunction{
#    Rewrite(x => y),
#    `DefineFunction{
#        Rewrite(!x),
#        Rewrite(!y)
#    }
#}
#
#Apply{f@Symbol, args@List}: body => `DefineFunction{Apply{!f, !args}, !body}
#x@Symbol: value => `DefineVariable{!x, !value}
#
prefix UnaryPlus    "+"  5
prefix UnaryMinus   "-"  5
prefix Not          "not"5
infixl Times        "*"  6
infixl Divide       "/"  6
infixl Mod          "%"  6
infixl Plus         "+"  7
infixl Minus        "-"  7
infixl LessThan     "<"  9 
infixl GreaterThan  ">"  9
infixl LessEqual    "<=" 9
infixl GreaterEqual ">=" 9
infixl Equal        "==" 10
infixl NotEqual     "!=" 10
infixl LogicalAnd   "&&" 11
infixl LogicalOr    "||" 12
infixr Lambda       "->" 13
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

#true: \true
#false: \false

#+x     => `UnaryPlus(!x)
#-x     => `UnaryMinus(!x)
#not x  => `Not(!x)
#x * y  => `Times(!x, !y)
#x / y  => `Divide(!x, !y)
#x % y  => `Mod(!x, !y)
#x + y  => `Plus(!x, !y)
#x - y  => `Minus(!x, !y)
#x < y  => `LessThan(!x, !y)
#x > y  => `GreaterThan(!x, !y)
#x >= y => `GreaterEqual(!x, !y)
#x <= y => `LessEqual(!x, !y)
#x += y => `(!x = !x + !y)
#x -= y => `(!x = !x - !y)
#x *= y => `(!x = !x * !y)
#x /= y => `(!x = !x / !y)
#x %= y => `(!x = !x % !y)
#x[y]   => `Subscript(!x, !y)

}
