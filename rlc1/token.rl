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
TOK_COMMENT    => 259;
TOK_IDENT      => 260;
TOK_COMMAND    => 261;
TOK_REWRITE    => 262;
TOK_ADDASGN    => 263;
TOK_SUBASGN    => 264;
TOK_MULASGN    => 265;
TOK_DIVASGN    => 266;
TOK_MODASGN    => 267;
TOK_ORASGN     => 268;
TOK_XORASGN    => 269;
TOK_ANDASGN    => 270;
TOK_LSHIFTASGN => 271;
TOK_RSHIFTASGN => 272;
TOK_LSHIFT     => 273;
TOK_RSHIFT     => 274;
TOK_EQ         => 275;
TOK_NE         => 276;
TOK_LE         => 277;
TOK_GE         => 278;
TOK_SEQAND     => 279;
TOK_SEQOR      => 280;
TOK_INCR       => 281;
TOK_DECR       => 282;
TOK_ELSE       => 283;
