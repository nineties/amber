(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: code.rl 2010-04-10 00:17:29 nineties $
 %);

NODE_PROG       => 0;  (% item list %);
NODE_INTEGER    => 1;  (% type, bits, value %);
NODE_STRING     => 2;  (% type, string %);
NODE_DONTCARE   => 3;  (% type %);
NODE_IDENTIFIER => 4;  (% type, name, id, tyscheme, is_global %);
NODE_ARRAY      => 5;  (% type, length, elements %);
NODE_TUPLE      => 6;  (% type, length, elements %);
NODE_BLOCK      => 7;  (% type, elements %);
NODE_DECL       => 8;  (% type, lhs, rhs %);
NODE_CALL       => 9;  (% operator() : type, lhs, tuple of arguments, closure call %);
NODE_SUBSCRIPT  => 10; (% operator[] : type, lhs, index %);
NODE_LAMBDA     => 11; (% operator{} : type, lhs, code, label, free vars %);
NODE_UNEXPR     => 12; (% type, operator, arg %);
NODE_BINEXPR    => 13; (% type, operator, lhs, rhs %);
NODE_ASSIGN     => 14; (% type, operator, lhs, rhs %);
NODE_EXPORT     => 15; (% item %);
NODE_IMPORT     => 16; (% module name %);
NODE_EXTERNAL   => 17; (% ident, type %);
NODE_RET        => 18; (% type %);
NODE_RETVAL     => 19; (% type, value %);
NODE_SYSCALL    => 20; (% type, params %);
NODE_FIELD      => 21; (% type, lhs, rhs %);
NODE_FIELDREF   => 22; (% type, lhs, name %);
NODE_TYPEDECL   => 23; (% name, type %);
NODE_VARIANT    => 24; (% type, constructor name, id, arg %);
NODE_UNIT       => 25; (% type, 0, NULL %);
NODE_TYPEDEXPR  => 26; (% type, expr %);
NODE_IF         => 27; (% type, cond, body %);
NODE_IFELSE     => 28; (% type, cond, ifthen, ifelse %);
NODE_SARRAY     => 29; (% type, elem, length %);
NODE_CAST       => 30; (% type, expr %);
NODE_NEW        => 31; (% type, expr %);
NODE_WHILE      => 32; (% type, cond, body %);
NODE_FOR        => 33; (% type, init, cond, step, body %);
NODE_NEWARRAY   => 34; (% type, length, init %);

(% indices %);
STRING_RAW       => 2;
ARRAY_LENGTH     => 2;
ARRAY_ELEMENTS   => 3;
TUPLE_LENGTH     => 2;
TUPLE_ELEMENTS   => 3;
BLOCK_STATEMENTS => 2;
LAMBDA_ARG       => 2;
LAMBDA_BODY      => 3;
SUBSCRIPT_LHS    => 2;
SUBSCRIPT_RHS    => 3;
CALL_FUN         => 2;
CALL_ARG         => 3;
RETVAL_VALUE     => 2;

(% types %);
NODE_UNIT_T     => 0;
NODE_CHAR_T     => 1;
NODE_INT_T      => 2;
NODE_FLOAT_T    => 3;
NODE_DOUBLE_T   => 4;
NODE_POINTER_T  => 5;  (% element type %);
NODE_ARRAY_T    => 6;  (% element type %);
NODE_TUPLE_T    => 7;  (% length, element types  %);
NODE_LAMBDA_T   => 8;  (% param type, ret type %);
NODE_TYVAR      => 9;  (% type-variable id %);
NODE_NAMED_T    => 10; (% fieldname, type %);
NODE_VARIANT_T  => 11; (% name, rows %);
NODE_VOID_T     => 12;
NODE_SARRAY_T   => 13; (% element type %);
NODE_ABSTRACT_T => 14;

(% structure of rows of variant
 % (constructor name, id, arg)
 %);

POINTER_T_BASE    => 1;
ARRAY_T_ELEMENT   => 1;
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
OPD_PSEUDO   => 0; (% id, pseudo-id, length, location type, allocated-locations %);
OPD_REGISTER => 1; (% id, index %);
OPD_STACK    => 2; (% id, offset %);
OPD_ARG      => 3; (% id, offset %);
OPD_AT       => 4; (% id, register, index %);
OPD_INTEGER  => 5; (% value %);
OPD_CHAR     => 6; (% value %);
OPD_FLOAT    => 7; (% value %);
OPD_ADDRESS  => 8; (% name %);
OPD_LABEL    => 9; (% name %);
OPD_OFFSET   => 10; (% id, register, label, size %);

PSUEOD_ID       => 2;
PSEUDO_LENGTH   => 3;
PSEUDO_TYPE     => 4;
PSEUDO_LOCATION => 5;
REGISTER_INDEX  => 2;
STACK_OFFSET    => 2;
ARG_OFFSET      => 2;

LOCATION_ANY      => 0;
LOCATION_REGISTER => 1;
LOCATION_MEMORY   => 2; (% must be continuous memory %);

DATA_CHAR   => 0; (% value %);
DATA_INT    => 1; (% value %);
DATA_FLOAT  => 2; (% value %);
DATA_DOUBLE => 3; (% value %);
DATA_TUPLE  => 4; (% length, values %);
DATA_ARRAY  => 5; (% length, values %);
DATA_STRING => 6; (% string %);
DATA_LABEL  => 7; (% name %);
DATA_SARRAY => 8; (% size, bits %);

TCODE_SKIP   => 0; (% byte %);
TCODE_DATA   => 1; (% label name, data, export %);
TCODE_FUNC   => 2; (% label name, parameters, instructions, export %);
TCODE_INST   => 3; (% opcode, output reg, input reg, live regs, arg, alive %);

INST_OPCODE   => 1;
INST_OPERAND1 => 2;
INST_OPERAND2 => 3;
INST_LIVEOUT  => 4;
INST_ARG      => 5;
INST_LIVEIN   => 6;

OPD_NONE   => 0;
OPD_INPUT  => 1;
OPD_OUTPUT => 2;
OPD_INOUT  => 3;

INST_MOVL     => 0;
INST_PUSHL    => 1;
INST_POPL     => 2;
INST_RET      => 3; (% INST_ARG == TRUE if it is retval instruction %);
INST_LEAVE    => 4;
INST_INT      => 5; (% INST_ARG is the number of arguments %);
INST_CALL_IMM => 6; (% immediate call, INST_ARG is the number of arguments %);
INST_CALL_IND => 7; (% indirect call, INST_ARG is the number of arguments %);
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
INST_LEAL     => 22; (% load effective address %);
INST_STORE    => 23;
INST_LOAD     => 24;
INST_CMPL     => 25;
INST_JMP      => 26;
INST_JE       => 27;
INST_JNE      => 28;
INST_JA       => 29;
INST_JAE      => 30;
INST_JB       => 31;
INST_JBE      => 32;
INST_LABEL    => 33;
INST_STOREB   => 34;
INST_LOADB    => 35;
