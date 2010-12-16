#!../rowl1/rowl

# rowl - generation 2
# Copyright (C) 2010 nineties
#
# $Id: syntax.rl 2010-12-16 02:30:09 nineties $

# Syntax definition of rowl language

syntax_sugar(HeadIs,        InfixL("!", 3))
syntax_sugar(UnaryPlus,     Prefix("+", 4))
syntax_sugar(UnaryMinus,    Prefix("-", 4))
syntax_sugar(Not,           Prefix("!", 4))
syntax_sugar(Times,         InfixL("*", 6))
syntax_sugar(Divide,        InfixL("/", 6))
syntax_sugar(Mod,           InfixL("%", 6))
syntax_sugar(Plus,          InfixL("+", 7))
syntax_sugar(Minus,         InfixL("-", 7))
syntax_sugar(Less,          InfixL("<", 9))
syntax_sugar(Greater,       InfixL(">", 9))
syntax_sugar(LessThan,      InfixL("<=", 9))
syntax_sugar(GreaterThan,   InfixL(">=", 9))
syntax_sugar(Equal,         InfixL("==", 10))
syntax_sugar(NotEqual,      InfixL("!=", 10))
syntax_sugar(And,           InfixL("&", 11))
syntax_sugar(Xor,           InfixL("^", 12))
syntax_sugar(Or,            InfixL("|", 13))
syntax_sugar(LogicalAnd,    InfixL("&&", 14))
syntax_sugar(LogicalOr,     InfixL("||", 15))
syntax_sugar(Assign,        InfixL("=", 17))
syntax_sugar(PlusAssign,    InfixR("+=", 17))
syntax_sugar(MinusAssign,   InfixR("-=", 17))
syntax_sugar(TimesAssign,   InfixR("*=", 17))
syntax_sugar(DivideAssign,  InfixR("/=", 17))
syntax_sugar(ModAssign,     InfixR("%=", 17))
syntax_sugar(Decl,          InfixR(":", 18))
syntax_sugar(If,            Constr("if"))
syntax_sugar(While,         Constr("while"))
syntax_sugar(For,           Constr("for"))
syntax_sugar(Return,        Command("return"))
syntax_sugar(Else,          InfixL("else", 19))
