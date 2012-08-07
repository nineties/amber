/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: token.s 2010-01-15 21:03:34 nineties $ */

/* token code:
   Codes of single ascii character tokens are same with their ascii codes.
 */
.set TOK_INT,       256 /* integer literal */
.set TOK_STRING,    257 /* string literal */
.set TOK_IDENT,     258 /* identifier */
.set TOK_MACRO,     259 /* macro constant */
.set TOK_XVAR,      260 /* local variable */
.set TOK_PVAR,      261 /* parameter variable */
.set TOK_IF,        262
.set TOK_ELSE,      263
.set TOK_WHILE,     264
.set TOK_GOTO,      265
.set TOK_LABEL,     266
.set TOK_RETURN,    267
.set TOK_SYSCALL,   268
.set TOK_EXPORT,    269
.set TOK_ALLOCATE,  270
.set TOK_INCLUDE,   271
.set TOK_WCH,       272
.set TOK_RCH,       273
.set TOK_TINT,      274
.set TOK_TCHAR,     275
.set TOK_EQ,        276 /* == */
.set TOK_NE,        277 /* != */
.set TOK_LE,        278 /* <= */
.set TOK_GE,        279 /* >= */
.set TOK_DARROW,    280 /* => */
.set TOK_END,       281 /* end of token */

.set RESERVED_WORDS_ID_BEGIN,262

.set MAX_TOKEN_LEN, 512
