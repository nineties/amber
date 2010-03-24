(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: code.rl 2010-03-25 03:08:06 nineties $
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
NODE_CALL       => 9;  (% operator() : type, lhs, tuple of arguments %);
NODE_SUBSCRIPT  => 10; (% operator[] : type, lhs, array of arguments %);
NODE_LAMBDA     => 11; (% operator{} : type, lhs, code %);
NODE_UNEXPR     => 12; (% type, operator, arg %);
NODE_BINEXPR    => 13; (% type, operator, lhs, rhs %);
NODE_ASSIGN     => 14; (% type, operator, lhs, rhs %);
NODE_RET        => 15; (% type %);
NODE_RETVAL     => 16; (% type, value %);
NODE_EXPORT     => 17; (% item %);

(% indices %);
STRING_RAW      => 2;
CODE_STATEMENTS => 2;
LAMBDA_ARG      => 2;
LAMBDA_BODY     => 3;
SUBSCRIPT_LHS   => 2;
SUBSCRIPT_RHS   => 3;
CALL_FUN        => 2;
CALL_ARG        => 3;
RETVAL_VALUE    => 2;

(% types %);
NODE_VOID_T    => 0;
NODE_CHAR_T    => 1;
NODE_INT_T     => 2;
NODE_FLOAT_T   => 3;
NODE_DOUBLE_T  => 4;
NODE_POINTER_T => 5; (% element type %);
NODE_ARRAY_T   => 6; (% element type, length, is_string %);
NODE_TUPLE_T   => 7; (% length, element types  %);
NODE_LAMBDA_T  => 8; (% param type, ret type %);
NODE_TYVAR     => 9; (% type-variable id %);

POINTER_T_BASE    => 1;
ARRAY_T_ELEMENT   => 1;
ARRAY_T_LENGTH    => 2;
ARRAY_T_IS_STRING => 3;
TUPLE_T_LENGTH    => 1;
TUPLE_T_ELEMENTS  => 2;
LAMBDA_T_PARAM    => 1;
LAMBDA_T_RETURN   => 2;
TYVAR_ID          => 1;

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


(% Three-address Code %);

(% operands %);
OPD_PSEUDO   => 0; (% id, null %);
OPD_REGISTER => 1; (% id, address %);
OPD_STACK    => 2; (% id, position %);
OPD_INTEGER  => 3; (% value %);
OPD_CHAR     => 4; (% value %);
OPD_FLOAT    => 5; (% value %);
OPD_ADDRESS  => 6; (% name %);
OPD_CONTENT  => 7; (% name %);

DATA_CHAR   => 0; (% value %);
DATA_INT    => 1; (% value %);
DATA_FLOAT  => 2; (% value %);
DATA_DOUBLE => 3; (% value %);
DATA_TUPLE  => 4; (% length, values %);
DATA_ARRAY  => 5; (% length, values %);
DATA_STRING => 6; (% string %);
DATA_LABEL  => 7; (% name %);

TCODE_SKIP   => 0; (% byte %);
TCODE_DATA   => 1; (% label name, data, export %);
TCODE_FUNC   => 2; (% label name, parameters, instructions, export %);
TCODE_INST   => 3; (% opcode, output reg, input reg1, input reg2 %);

INST_MOVL => 0;
INST_RET  => 1;

