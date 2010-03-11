(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: token.rl 2010-02-27 15:57:22 nineties $ 
 %);

(%
 % Token code:
 % Codes of single ascii character tokens are same with their ascii codes.
 %);

TOK_END        => 256;
TOK_INT        => 257;
TOK_STRING     => 258;
TOK_IDENT      => 259;
TOK_REWRITE    => 260;
TOK_ADDASGN    => 261;
TOK_SUBASGN    => 262;
TOK_MULASGN    => 263;
TOK_DIVASGN    => 264;
TOK_MODASGN    => 265;
TOK_ORASGN     => 266;
TOK_XORASGN    => 267;
TOK_ANDASGN    => 268;
TOK_LSHIFTASGN => 269;
TOK_RSHIFTASGN => 270;
TOK_LSHIFT     => 271;
TOK_RSHIFT     => 272;
TOK_EQ         => 273;
TOK_NE         => 274;
TOK_LE         => 275;
TOK_GE         => 276;
TOK_SEQAND     => 277;
TOK_SEQOR      => 278;
TOK_INCR       => 279;
TOK_DECR       => 280;
TOK_RETURN     => 281;
