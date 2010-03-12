(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: code.rl 2010-02-22 18:06:23 nineties $ 
 %);

NODE_PROG       => 0;  (% item list %);
NODE_REWRITE    => 1;  (% lhs, rhs %);
NODE_INTEGER    => 2;  (% type, bits, value %);
NODE_STRING     => 3;  (% type, string %);
NODE_IDENTIFIER => 4;  (% type, name, id, tyscheme %);
NODE_ARRAY      => 5;  (% type, length, elements %);
NODE_TUPLE      => 6;  (% type, length, elements %);
NODE_CODE       => 7;  (% type, elements %);
NODE_DECL       => 8;  (% type, lhs, rhs %);
NODE_CALLOP     => 9;  (% operator() : type, lhs, tuple of arguments %);
NODE_SUBSOP     => 10; (% operator[] : type, lhs, array of arguments %);
NODE_CODEOP     => 11; (% operator{} : type, lhs, code %);
NODE_UNEXPR     => 12; (% type, operator, arg %);
NODE_BINEXPR    => 13; (% type, operator, lhs, rhs %);
NODE_ASSIGN     => 14; (% type, operator, lhs, rhs %);
NODE_RET        => 15; (% type %);
NODE_RETVAL     => 16; (% type, value %);

(% types %);
NODE_VOID_T     => 0;
NODE_CHAR_T     => 1;
NODE_INT_T      => 2;
NODE_FLOAT_T    => 3;
NODE_DOUBLE_T   => 4;
NODE_ARRAY_T    => 5; (% element type, is_string %);
NODE_TUPLE_T    => 6; (% length, element types  %);
NODE_FUNCTION_T => 7; (% param type, ret type %);
NODE_TYVAR      => 8; (% type-variable id %);

(% unary operators %);
UNOP_PLUS      => 0;
UNOP_MINUS     => 1;
UNOP_INVERSE   => 2;
UNOP_NOT       => 3;
UNOP_ADDRESSOF => 4;
UNOP_INDIRECT  => 5;
UNOP_PREINCR   => 6;
UNOP_PREDECR   => 7;
UNOP_POSTINCR  => 8;
UNOP_POSTDECR  => 9;

(% binary operators %);
BINOP_NONE   => 0;  (% for simple assignment expression %);
BINOP_ADD    => 1;
BINOP_SUB    => 2;
BINOP_MUL    => 3;
BINOP_DIV    => 4;
BINOP_MOD    => 5;
BINOP_OR     => 6;
BINOP_XOR    => 7;
BINOP_AND    => 8;
BINOP_LSHIFT => 9;
BINOP_RSHIFT => 10;
BINOP_EQ     => 11;
BINOP_NE     => 12;
BINOP_LT     => 13;
BINOP_GT     => 14;
BINOP_LE     => 15;
BINOP_GE     => 16;
BINOP_SEQOR  => 17;
BINOP_SEQAND => 18;
