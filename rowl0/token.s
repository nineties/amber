/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: token.s 2010-01-15 21:03:34 nineties $ */

/* token code:
   Codes of single ascii character tokens are same with their ascii codes.
 */
.equ TOK_INT,       256 /* integer literal */
.equ TOK_STRING,    257 /* string literal */
.equ TOK_IDENT,     258 /* identifier */
.equ TOK_MACRO,     259 /* macro constant */
.equ TOK_XVAR,      260 /* local variable */
.equ TOK_PVAR,      261 /* parameter variable */
.equ TOK_IF,        262
.equ TOK_ELSE,      263
.equ TOK_WHILE,     264
.equ TOK_GOTO,      265
.equ TOK_LABEL,     266
.equ TOK_RETURN,    267
.equ TOK_SYSCALL,   268
.equ TOK_EXPORT,    269
.equ TOK_ALLOCATE,  270
.equ TOK_INCLUDE,   271
.equ TOK_WCH,       272
.equ TOK_RCH,       273
.equ TOK_TINT,      274
.equ TOK_TCHAR,     275
.equ TOK_EQ,        276 /* == */
.equ TOK_NE,        277 /* != */
.equ TOK_LE,        278 /* <= */
.equ TOK_GE,        279 /* >= */
.equ TOK_DARROW,    280 /* => */
.equ TOK_END,       281 /* end of token */

.equ RESERVED_WORDS_ID_BEGIN,262

.equ MAX_TOKEN_LEN, 512
