(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: code.rl 2010-03-27 21:11:35 nineties $
 %);

NODE_PROG       => 0;  (% item list %);
NODE_REWRITE    => 1;  (% lhs, rhs %);
NODE_INTEGER    => 2;  (% type, bits, value %);
NODE_STRING     => 3;  (% type, string %);
NODE_DONTCARE   => 4;  (% type %);
NODE_IDENTIFIER => 5;  (% type, name, id, tyscheme %);
NODE_ARRAY      => 6;  (% type, length, elements %);
NODE_TUPLE      => 7;  (% type, length, elements %);
NODE_CODE       => 8;  (% type, elements %);
NODE_DECL       => 9;  (% type, lhs, rhs %);
NODE_CALL       => 10; (% operator() : type, lhs, tuple of arguments %);
NODE_SUBSCRIPT  => 11; (% operator[] : type, lhs, array of arguments %);
NODE_LAMBDA     => 12; (% operator{} : type, lhs, code %);
NODE_UNEXPR     => 13; (% type, operator, arg %);
NODE_BINEXPR    => 14; (% type, operator, lhs, rhs %);
NODE_ASSIGN     => 15; (% type, operator, lhs, rhs %);
NODE_EXPORT     => 16; (% item %);
NODE_RET        => 17; (% type %);
NODE_RETVAL     => 18; (% type, value %);
NODE_SYSCALL    => 19; (% type, params %);

(% indices %);
STRING_RAW      => 2;
ARRAY_LENGTH    => 2;
ARRAY_ELEMENTS  => 3;
TUPLE_LENGTH    => 2;
TUPLE_ELEMENTS  => 3;
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
OPD_PSEUDO   => 0; (% id, pseudo-id, length, flag (TRUE if it must be a register), %);
OPD_REGISTER => 1; (% id, index %);
OPD_STACK    => 2; (% id, offset %);
OPD_ARG      => 3; (% id, offset %);
OPD_INTEGER  => 4; (% value %);
OPD_CHAR     => 5; (% value %);
OPD_FLOAT    => 6; (% value %);
OPD_ADDRESS  => 7; (% name %);
OPD_LABEL    => 8; (% name %);

PSUEOD_ID               => 2;
PSEUDO_LENGTH           => 3;
PSEUDO_MUST_BE_REGISTER => 4;
REGISTER_INDEX          => 2;
STACK_OFFSET            => 2;
STACK_LENGTH            => 3;
ARG_OFFSET              => 2;
ARG_LENGTH              => 3;

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
TCODE_INST   => 3; (% opcode, output reg, input reg, live regs, arg %);

INST_OPCODE => 1;
INST_OUTPUT => 2;
INST_INPUT  => 3;
INST_LIVE   => 4;
INST_ARG    => 5;

INST_MOVL     => 0;
INST_PUSHL    => 1;
INST_POPL     => 2;
INST_RET      => 3; (% ARG == TRUE if it is retval instruction %);
INST_LEAVE    => 4;
INST_INT      => 5; (% ARG is the number of arguments %);
INST_CALL_IMM => 6; (% immediate call %);
INST_CALL_IND => 7; (% indirect call %);
INST_ADDL     => 8;
INST_SUBL     => 9;
INST_IMUL     => 10;
INST_IDIV     => 11;
INST_IMOD     => 12;
INST_ORL      => 13;
INST_XORL     => 14;
INST_ANDL     => 15;
INST_SHLL     => 16;
INST_SHRL     => 17;
INST_NEGL     => 18;
INST_NOTL     => 19; (% bitwise inverse %);
INST_INCL     => 20;
INST_DECL     => 21;
