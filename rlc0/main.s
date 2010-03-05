/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: main.s 2010-01-15 00:43:33 nineties $ */

.include "defs.s"
.include "token.s"

.text

.global _main
_main:
    subl    $4, %esp
    call    _lex
    call    _program
    movl    $0, (%esp)
    call    _exit
