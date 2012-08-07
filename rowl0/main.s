/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: main.s 2010-03-25 01:53:49 nineties $ */

.include "defs.s"
.include "token.s"

.text

.globl _main
_main:
	subl    $4, %esp
	call    _lex
	call    _program
	movl    $0, (%esp)
	call    _exit
