(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: code.rl 2010-02-22 18:06:23 nineties $ 
 %);

NODE_PROG       => 0; (% item list %);
NODE_INTEGER    => 1; (% type, value %);
NODE_STRING     => 2; (% type, string %);
NODE_IDENTIFIER => 3; (% type, name, id, tyscheme %);
NODE_ARRAY      => 4; (% type, length, elements %);
NODE_LIST       => 5; (% type, elements %);
NODE_TUPLE      => 6; (% type, length, elements %);
NODE_REWRITE    => 7; (% left, right %);
NODE_EVAL       => 8; (% expression %);
NODE_DECL       => 9; (% type, lhs, rhs %);
NODE_PAT        => 10; (% symbol, length, pat-elems %);
NODE_ASM        => 11; (% code %);
NODE_CALLOP     => 12; (% operator() : type, lhs, tuple of arguments %);
NODE_SUBSOP     => 13; (% operator[] : type, lhs, array of arguments %);
NODE_CODEOP     => 14; (% operator{} : type, lhs, list of arguments %);
NODE_UNEXPR     => 15; (% type, operator, arg %);
NODE_BINEXPR    => 16; (% type, operator, lhs, rhs %);
NODE_ASSIGN     => 17; (% type, operator, lhs, rhs %);
NODE_RET        => 18; (% type %);
NODE_RETVAL     => 19; (% type, value %);

(% types %);
NODE_VOID_T     => 0;
NODE_BOOL_T     => 1;
NODE_CHAR_T     => 2;
NODE_INT_T      => 3;
NODE_INT64_T    => 4;
NODE_FLOAT_T    => 5;
NODE_DOUBLE_T   => 6;
NODE_ARRAY_T    => 7;  (% element type %);
NODE_LIST_T     => 8;  (% element type %);
NODE_TUPLE_T    => 9;  (% length, element types  %);
NODE_FUNCTION_T => 10; (% param type, ret type %);
NODE_TYVAR      => 11; (% type-variable id %);

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
