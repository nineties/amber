#!../rowl1/rowl

# rowl - generation 2
# Copyright (C) 2010 nineties
#
# $Id: main.rl 2010-12-15 16:04:01 nineties $

syntax_sugar(HeadPat, InfixL("!", 1))
syntax_sugar(UnaryPlus, Prefix("+", 2))
syntax_sugar(UnaryMinus, Prefix("-", 2))
syntax_sugar(Not, Prefix("!", 2))
syntax_sugar(Times, InfixL("*", 4))
syntax_sugar(Divide, InfixL("/", 4))
syntax_sugar(Mod, InfixL("%", 4))
syntax_sugar(Plus, InfixL("+", 5))
syntax_sugar(Minus, InfixL("-", 5))
syntax_sugar(Less, InfixL("<", 7))
syntax_sugar(Greater, InfixL(">", 7))
syntax_sugar(LessThan, InfixL("<=", 7))
syntax_sugar(GreaterThan, InfixL(">=", 7))
syntax_sugar(Equal, InfixL("==", 8))
syntax_sugar(NotEqual, InfixL("!=", 8))
syntax_sugar(And, InfixL("&", 9))
syntax_sugar(Xor, InfixL("^", 10))
syntax_sugar(Or, InfixL("|", 11))
syntax_sugar(LogicalAnd, InfixL("&&", 12))
syntax_sugar(LogicalOr, InfixL("||", 13))
syntax_sugar(Assign, InfixL("=", 15))
syntax_sugar(PlusAssign, InfixR("+=", 15))
syntax_sugar(MinusAssign, InfixR("-=", 15))
syntax_sugar(TimesAssign, InfixR("*=", 15))
syntax_sugar(DivideAssign, InfixR("/=", 15))
syntax_sugar(ModAssign, InfixR("%=", 15))
syntax_sugar(Decl, InfixR(":", 16))
syntax_sugar(If, Constr("if"))
syntax_sugar(While, Constr("while"))
syntax_sugar(For, Constr("for"))
syntax_sugar(Return, Command("return"))

#infixr(oper!String, assoc!Int, head!Symbol)  => syntax_sugar(head, InfixR(oper, assoc))
#infixl(oper!String, assoc!Int, head!Symbol)  => syntax_sugar(head, InfixL(oper, assoc))
#prefix(oper!String, assoc!Int, head!Symbol)  => syntax_sugar(head, Prefix(oper, assoc))
#postfix(oper!String, assoc!Int, head!Symbol) => syntax_sugar(head, Postfix(oper, assoc))
#constr(oper!String, head!Symbol)             => syntax_sugar(head, Constr(oper))
#command(oper!String, head!Symbol)            => syntax_sugar(head, Command(oper))

print("hello world\n")
print(1 + 2*3)
print(+1)

compile(if cond (body!Block)): {
    compile(cond)
    compile(body)
}

if (1) {
    print("Hello World\n")
}
