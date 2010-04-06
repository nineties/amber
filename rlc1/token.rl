(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: token.rl 2010-04-07 01:43:34 nineties $
 %);

(%
 % Token code:
 % Codes of single ascii character tokens are same with their ascii codes.
 %);

TOK_END        => 256;
TOK_CHAR       => 257;
TOK_INT        => 258;
TOK_STRING     => 259;
TOK_IDENT      => 260;
TOK_REWRITE    => 261;
TOK_ADDASGN    => 262;
TOK_SUBASGN    => 263;
TOK_MULASGN    => 264;
TOK_DIVASGN    => 265;
TOK_MODASGN    => 266;
TOK_ORASGN     => 267;
TOK_XORASGN    => 268;
TOK_ANDASGN    => 269;
TOK_LSHIFTASGN => 270;
TOK_RSHIFTASGN => 271;
TOK_LSHIFT     => 272;
TOK_RSHIFT     => 273;
TOK_EQ         => 274;
TOK_NE         => 275;
TOK_LE         => 276;
TOK_GE         => 277;
TOK_SEQAND     => 278;
TOK_SEQOR      => 279;
TOK_INCR       => 280;
TOK_DECR       => 281;
TOK_ARROW      => 282;
(% reserved words %);
TOK_EXPORT     => 283;
TOK_RETURN     => 284;
TOK_SYSCALL    => 285;
TOK_CHAR_T     => 286;
TOK_INT_T      => 287;
TOK_FLOAT_T    => 288;
TOK_DOUBLE_T   => 289;
TOK_TYPE       => 290;
TOK_CONSTR     => 290;
