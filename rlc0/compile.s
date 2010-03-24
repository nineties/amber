/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: compile.s 2010-03-24 22:05:35 nineties $ */

.include "defs.s"
.include "token.s"

.data

.equ STRING_BUFFER_LEN, 32768
.comm string_buffer,STRING_BUFFER_LEN,1
string_offs: .long 0
string_buflen: .long 0

.text

.section .rodata
string_buffer_text: .string "_string_literal_buffer"
.text

_strlen_with_escape:
    xorl    %eax, %eax
    movl    4(%esp), %ebx
1:
    movb    (%ebx), %cl
    cmpb    $0, %cl
    je      2f
    cmpb    $'\\, %cl
    je      3f
    incl    %ebx
    incl    %eax
    jmp     1b
2:
    ret
3:
    incl    %eax
    addl    $2, %ebx
    jmp     1b
    
_push_string:
    subl    $8, %esp
    movl    12(%esp), %eax
    movl    %eax, (%esp)
    call    _strlen_with_escape
    decl    %eax
    addl    %eax, string_offs
    movl    12(%esp), %eax
    movl    %eax, (%esp)
    call    _strlen
    decl    %eax
    addl    string_buflen, %eax
    cmpl    $STRING_BUFFER_LEN, %eax
    ja      1f
    movl    string_buflen, %ebx
    movl    %eax, string_buflen
    movl    $string_buffer, %eax
    addl    %ebx, %eax
    movl    %eax, (%esp)
    movl    12(%esp), %eax
    incl    %eax    /* skip first \" */
    movl    %eax, 4(%esp)
    call    _strcpy
    movl    string_buflen, %eax
    addl    $string_buffer, %eax
    decl    %eax
    movb    $0, (%eax)
    addl    $8, %esp
    ret
1:
    call    _flush
    pushl   output_fd
    pushl   $string_literals
    movl    $STDERR_FD, output_fd
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit

_put_string_addr:
    subl    $4, %esp
    movl    $string_buffer_text, (%esp)
    call    _puts
    movl    $'+, (%esp)
    call    _putc
    movl    string_offs, %eax
    movl    %eax, (%esp)
    call    _putnum
    addl    $4, %esp
    ret

_gen_string_literals:
    subl    $8, %esp
    cmpl    $0, string_buflen
    je      4f
    call    _enter_rodata_area
    movl    $string_buffer_text, (%esp)
    call    _puts
    movl    $':, (%esp)
    call    _putc
    call    _nl
    call    _dot_string
    movl    $'", (%esp)
    call    _putc
    movl    $0, 4(%esp) /* counter */
1:
    movl    4(%esp), %eax
    cmpl    %eax, string_buflen
    je      2f
    xorl    %eax, %eax
    movl    $string_buffer, %ebx
    addl    4(%esp), %ebx
    movb    (%ebx), %al
    cmpb    $0, %al
    jne     3f
    movl    4(%esp), %eax
    incl    %eax
    cmpl    %eax, string_buflen
    je      2f
    movl    $'", (%esp)
    call    _putc
    call    _nl
    call    _dot_string
    movl    $'", (%esp)
    call    _putc
    incl    4(%esp)
    jmp     1b
3:
    movl    %eax, (%esp)
    call    _putc
    incl    4(%esp)
    jmp     1b
2:
    movl    $'", (%esp)
    call    _putc
    call    _nl
    addl    $8, %esp
    ret
4:
    addl    $8, %esp
    ret

.section .rodata
string_literals: .string "ERROR: too many string literals\n"
.text

.global _program
_program:
    call    _enter_text_area
    cmpl    $TOK_END, token_tag
    je      1f
3:
    call    _external_item
    call    _lex
    cmpl    $TOK_END, token_tag
    je      1f
    cmpl    $';, token_tag
    je      2f
    call    _syntax_error
2:
    call    _lex
    cmpl    $TOK_END, token_tag
    jne     3b
1:
    call    _gen_string_literals
    ret

_external_item_list:
1:
    cmpl    $TOK_END, token_tag
    je      2f
    call    _external_item
    call    _lex
    cmpl    $';, token_tag
    jne     2f
    call    _lex
    jmp     1b
2:
    cmpl    $TOK_END, token_tag
    jne     3f
    ret
3:
    call    _syntax_error

_external_item:
    call    _item
    ret

.global _item
_item:
    cmpl    $TOK_GOTO, token_tag
    je      1f
    cmpl    $TOK_LABEL, token_tag
    je      2f
    cmpl    $TOK_RETURN, token_tag
    je      3f
    cmpl    $TOK_SYSCALL, token_tag
    je      4f
    cmpl    $TOK_EXPORT, token_tag
    je      5f
    cmpl    $TOK_IF, token_tag
    je      6f
    cmpl    $TOK_ALLOCATE, token_tag
    je      9f
    cmpl    $TOK_WHILE, token_tag
    je      10f
    cmpl    $TOK_WCH, token_tag
    je      11f
    cmpl    $TOK_INCLUDE, token_tag
    je      12f
    call    _toplevel_expr
    ret
1:
    call    _lex
    call    _or_expr
    call    _jmp
    pushl   $'*
    call    _putc
    addl    $4, %esp
    call    _eax
    call    _nl
    ret
2:
    call    _lex
    call    _ident
    pushl   $token_text
    call    _puts
    movl    $':, (%esp)
    call    _putc
    call    _nl
    addl    $4, %esp
    ret
3:
    call    _lex
    cmpl    $';, token_tag
    je      13f
    cmpl    $'}, token_tag
    je      13f
    call    _or_expr
    call    _leave
    call    _nl
    call    _ret
    call    _nl
    ret
13:
    call    _lex_unput
    call    _leave
    call    _nl
    call    _ret
    call    _nl
    ret
4:
    call    _syscall
    ret
5:
    call    _export
    ret
6:
    subl    $8, %esp
    call    _new_labelid
    movl    %eax, 4(%esp)
    call    _lex
    movl    $'(, (%esp)
    call    _symbol

    call    _lex
    call    _or_expr

    call    _lex
    movl    $'), (%esp)
    call    _symbol

    call    _cmpl
    movl    $0, (%esp)
    call    _integer
    call    _comma
    call    _eax
    call    _nl

    call    _je
    movl    4(%esp), %eax
    movl    %eax, (%esp)
    call    _label
    call    _nl

    call    _lex
    call    _block

    call    _lex
    cmpl    $TOK_ELSE, token_tag
    jne     7f

    call    _jmp
    call    _new_labelid
    movl    %eax, (%esp)
    call    _label
    call    _nl

    movl    4(%esp), %eax
    movl    (%esp), %ebx
    movl    %ebx, 4(%esp)
    movl    %eax, (%esp)
    call    _labeldef
    call    _nl

    call    _lex
    call    _block
    jmp     8f
7:
    call    _lex_unput
8:
    movl    4(%esp), %eax
    movl    %eax, (%esp)
    call    _labeldef
    call    _nl

    addl    $8, %esp
    ret
9:
    call    _lex
    call    _simple_item
    call    _imul
    pushl   $4
    call    _integer
    addl    $4, %esp
    call    _comma
    call    _eax
    call    _nl
    call    _subl
    call    _eax
    call    _comma
    call    _esp
    call    _nl
    ret
10:
    subl    $12, %esp
    call    _new_labelid
    movl    %eax, 8(%esp)
    call    _new_labelid
    movl    %eax, 4(%esp)
    movl    %eax, (%esp)
    call    _labeldef
    call    _nl

    call    _lex
    movl    $'(, (%esp)
    call    _symbol
    call    _lex
    call    _or_expr
    call    _lex
    movl    $'), (%esp)
    call    _symbol

    call    _cmpl
    movl    $0, (%esp)
    call    _integer
    call    _comma
    call    _eax
    call    _nl

    call    _je
    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _label
    call    _nl

    call    _lex
    call    _block

    call    _jmp
    movl    4(%esp), %eax
    movl    %eax, (%esp)
    call    _label
    call    _nl

    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _labeldef
    call    _nl

    addl    $12, %esp
    ret
11: /* wrch(ary,idx,val) == *(ary+idx) = val */
    subl    $4, %esp
    call    _lex
    movl    $'(, (%esp)
    call    _symbol

    call    _lex
    call    _or_expr
    call    _pushl_eax

    call    _lex
    movl    $',, (%esp)
    call    _symbol

    call    _lex
    call    _or_expr
    call    _popl_ebx
    call    _addl
    call    _ebx
    call    _comma
    call    _eax
    call    _nl
    call    _pushl_eax

    call    _lex
    movl    $',, (%esp)
    call    _symbol

    call    _lex
    call    _or_expr
    call    _popl_ebx
    call    _movb
    call    _al
    call    _comma
    movl    $'(, (%esp)
    call    _putc
    call    _ebx
    movl    $'), (%esp)
    call    _putc
    call    _nl

    call    _lex
    movl    $'), (%esp)
    call    _symbol
    addl    $4, %esp
    ret
12:
    call    _include
    ret

_syscall:
    subl    $4, %esp
    call    _pushl_esi
    call    _pushl_edi
    call    _pushl_ebp
    call    _lex
    call    _args
    cmpl    $7, %eax
    je      1f
    cmpl    $6, %eax
    je      2f
    cmpl    $5, %eax
    je      3f
    cmpl    $4, %eax
    je      4f
    cmpl    $3, %eax
    je      5f
    cmpl    $2, %eax
    je      6f
    jmp     7f
1:  call    _popl_ebp
2:  call    _popl_edi
3:  call    _popl_esi
4:  call    _popl_edx
5:  call    _popl_ecx
6:  call    _popl_ebx
7:  call    _popl_eax
    call    _int
    movl    $128, (%esp)
    call    _integer
    call    _nl
    call    _popl_ebp
    call    _popl_edi
    call    _popl_esi
    addl    $4, %esp
    ret

_args:
    subl    $8, %esp
    movl    $0, 4(%esp)  /* number of arguments */
    movl    $'(, (%esp)
    call    _symbol
    call    _lex
    cmpl    $'), token_tag
    je      2f
1:
    incl    4(%esp)
    call    _or_expr
    call    _pushl_eax
    call    _lex
    cmpl    $',, %eax
    jne     2f
    call    _lex
    jmp     1b
2:
    movl    $'), (%esp)
    call    _symbol
    movl    4(%esp), %eax
    addl    $8, %esp
    ret

_export:
    call    _dot_global
    call    _lex
    cmpl    $'(, token_tag
    jne     1f
    call    _identlist
    ret
1:
    call    _ident
    pushl   $token_text
    call    _puts
    addl    $4, %esp
    call    _nl
    ret

_identlist:
    subl    $4, %esp
    call    _lex
1:
    call    _ident
    movl    $token_text, (%esp)
    call    _puts
    call    _lex
    cmpl    $',, token_tag
    jne     2f
    movl    $',, (%esp)
    call    _putc
    call    _lex
    jmp     1b
2:
    movl    $'), (%esp)
    call    _symbol
    call    _nl
    addl    $4, %esp
    ret

_include:
    call    _lex
    cmpl    $'(, token_tag
    jne     1f
    call    _filelist
    ret
1:
    call    _ident
    call    _dot_include
    pushl   $token_text
    call    _putfile
    addl    $4, %esp
    call    _nl
    ret

_filelist:
    subl    $4, %esp
    call    _lex
1:
    call    _ident
    call    _dot_include
    movl    $token_text, (%esp)
    call    _putfile
    call    _nl
    call    _lex
    cmpl    $',, token_tag
    jne     2f
    call    _lex
    jmp     1b
2:
    movl    $'), (%esp)
    call    _symbol
    addl    $4, %esp
    ret

_putfile:
    subl    $4, %esp
    movl    $'", (%esp)
    call    _putc
    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _puts
    movl    $'., (%esp)
    call    _putc
    movl    $'s, (%esp)
    call    _putc
    movl    $'", (%esp)
    call    _putc
    addl    $4, %esp
    ret

_toplevel_expr:
    cmpl    $TOK_IDENT, token_tag
    je      1f
    cmpl    $TOK_MACRO, token_tag
    je      1f
    cmpl    $TOK_XVAR, token_tag
    je      8f
    cmpl    $TOK_PVAR, token_tag
    je      11f
    cmpl    $'*, token_tag
    je      2f
    call    _simple_item
    jmp     7f
1:
    pushl   $token_text
    call    _push_ident
    addl    $4, %esp
    call    _lex
    cmpl    $':, token_tag
    je      3f
    cmpl    $'=, token_tag
    je      4f
    cmpl    $'(, token_tag
    je      5f
    cmpl    $'[, token_tag
    je      6f
    cmpl    $TOK_DARROW, token_tag
    je      14f
    call    _syntax_error
2:
    subl    $4, %esp
    call    _lex
    call    _prefix_expr
    call    _pushl_eax
    call    _lex
    movl    $'=, (%esp)
    call    _symbol
    call    _or_expr
    call    _popl_ebx
    call    _movl
    call    _eax
    movl    $'(, (%esp)
    call    _putc
    call    _ebx
    movl    $'), (%esp)
    call    _putc
    call    _nl
3: /* identifier declaration */
    call    _lex
    call    _declaration
    ret
4:
    call    _lex
    call    _or_expr
    call    _movl
    call    _eax
    call    _comma
    pushl   $0
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    addl    $4, %esp
    call    _pop_ident
    call    _nl
    ret
5:
    call    _funcall
    ret
6:
    call    _movl
    pushl   $0
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    addl    $4, %esp
    call    _pop_ident
    call    _comma
    call    _eax
    call    _nl
7:
    subl    $4, %esp
    call    _pushl_eax
    call    _lex
    call    _or_expr
    call    _pushl_eax
    call    _lex
    movl    $'], (%esp)
    call    _symbol
    call    _lex
    movl    $'=, (%esp)
    call    _symbol

    call    _lex
    call    _or_expr

    call    _popl_ecx
    call    _popl_ebx
    /* gen *(ebx + 4*ecx) = eax */

    call    _imul
    movl    $4, (%esp)
    call    _integer
    call    _comma
    call    _ecx
    call    _nl

    call    _addl
    call    _ecx
    call    _comma
    call    _ebx
    call    _nl

    call    _movl
    call    _eax
    call    _comma
    movl    $'(, (%esp)
    call    _putc
    call    _ebx
    movl    $'), (%esp)
    call    _putc
    call    _nl
    addl    $4, %esp
    ret
8:
    subl    $4, %esp
    movl    token_val, %eax
    movl    %eax, (%esp)
    call    _lex
    movl    (%esp), %eax
    addl    $4, %esp
    cmpl    $'=, token_tag
    je      9f
    cmpl    $'[, token_tag
    je      10f
    cmpl    $'(, token_tag
    je      17f
    call    _syntax_error
9:
    subl    $4, %esp
    movl    %eax, (%esp)
    call    _lex
    call    _or_expr
    call    _movl
    call    _eax
    call    _comma
    call    _xvar
    call    _nl
    addl    $4, %esp
    ret
10:
    subl    $4, %esp
    movl    %eax, (%esp)
    call    _movl
    call    _xvar
    call    _comma
    call    _eax
    call    _nl
    addl    $4, %esp
    jmp     7b
11:
    subl    $4, %esp
    movl    token_val, %eax
    movl    %eax, (%esp)
    call    _lex
    movl    (%esp), %eax
    addl    $4, %esp
    cmpl    $'=, token_tag
    je      12f
    cmpl    $'[, token_tag
    je      13f
    cmpl    $'(, token_tag
    je      18f
    call    _syntax_error
12:
    subl    $4, %esp
    movl    %eax, (%esp)
    call    _lex
    call    _or_expr
    call    _movl
    call    _eax
    call    _comma
    call    _pvar
    call    _nl
    addl    $4, %esp
    ret
13:
    subl    $4, %esp
    movl    %eax, (%esp)
    call    _movl
    call    _pvar
    call    _comma
    call    _eax
    call    _nl
    addl    $4, %esp
    jmp     7b
14:
    subl    $4, %esp
    call    _dot_equ
    movl    $0, (%esp)
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    call    _pop_ident
    call    _comma
    call    _lex
    cmpl    $TOK_INT, token_tag
    je      16f
    cmpl    $TOK_IDENT, token_tag
    je      16f
    cmpl    $'-, token_tag
    je      15f
    addl    $4, %esp
    call    _syntax_error
15:
    movl    $'-,(%esp)
    call    _putc
    call    _lex
    cmpl    $TOK_INT, token_tag
    je      16f
    cmpl    $TOK_IDENT, token_tag
    je      16f
    addl    $4, %esp
    call    _syntax_error
16:
    movl    $token_text, (%esp)
    call    _puts
    call    _nl
    addl    $4, %esp
    ret
17:
    subl    $4, %esp
    movl    %eax, (%esp)
    call    _movl
    call    _xvar
    call    _comma
    call    _eax
    call    _nl
    call    _indcall
    addl    $4, %esp
    ret
18:
    subl    $4, %esp
    movl    %eax, (%esp)
    call    _movl
    call    _pvar
    call    _comma
    call    _eax
    call    _nl
    call    _indcall
    addl    $4, %esp
    ret

_or_expr:
    call    _xor_expr
1:
    call    _lex
    cmpl    $'|, token_tag
    je      2f
    call    _lex_unput
    ret
2:
    call    _pushl_eax
    call    _lex
    call    _xor_expr
    call    _popl_ebx
    call    _orl
    call    _ebx
    call    _comma
    call    _eax
    call    _nl
    jmp     1b

_xor_expr:
    call    _and_expr
1:
    call    _lex
    cmpl    $'^, token_tag
    je      2f
    call    _lex_unput
    ret
2:
    call    _pushl_eax
    call    _lex
    call    _and_expr
    call    _popl_ebx
    call    _xorl
    call    _ebx
    call    _comma
    call    _eax
    call    _nl
    jmp     1b

_and_expr:
    call    _equality_expr
1:
    call    _lex
    cmpl    $'&, token_tag
    je      2f
    call    _lex_unput
    ret
2:
    call    _pushl_eax
    call    _lex
    call    _equality_expr
    call    _popl_ebx
    call    _andl
    call    _ebx
    call    _comma
    call    _eax
    call    _nl
    jmp     1b

_equality_expr:
    call    _relational_expr
1:
    call    _lex
    cmpl    $TOK_EQ, token_tag
    je      2f
    cmpl    $TOK_NE, token_tag
    je      3f
    call    _lex_unput
    ret
2:
    call    _pushl_eax
    call    _lex
    call    _relational_expr
    call    _movl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _popl_eax
    call    _cmpl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _sete
    call    _al
    call    _nl
    call    _movzbl
    call    _al
    call    _comma
    call    _eax
    call    _nl
    jmp     1b
3:
    call    _pushl_eax
    call    _lex
    call    _relational_expr
    call    _movl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _popl_eax
    call    _cmpl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _setne
    call    _al
    call    _nl
    call    _movzbl
    call    _al
    call    _comma
    call    _eax
    call    _nl
    jmp     1b

_relational_expr:
    call    _additive_expr
6:
    call    _lex
    cmpl    $'<, token_tag
    je      1f
    cmpl    $'>, token_tag
    je      2f
    cmpl    $TOK_LE, token_tag
    je      3f
    cmpl    $TOK_GE, token_tag
    je      4f
    call    _lex_unput
    ret
1:
    call    _pushl_eax
    call    _lex
    call    _additive_expr
    call    _popl_ebx
    call    _cmpl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _setl
    call    _al
    call    _nl
    call    _movzbl
    call    _al
    call    _comma
    call    _eax
    call    _nl
    jmp     6b
2:
    call    _pushl_eax
    call    _lex
    call    _additive_expr
    call    _popl_ebx
    call    _cmpl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _setg
    call    _al
    call    _nl
    call    _movzbl
    call    _al
    call    _comma
    call    _eax
    call    _nl
    jmp     6b
3:
    call    _pushl_eax
    call    _lex
    call    _additive_expr
    call    _popl_ebx
    call    _cmpl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _setle
    call    _al
    call    _nl
    call    _movzbl
    call    _al
    call    _comma
    call    _eax
    call    _nl
    jmp     6b
4:
    call    _pushl_eax
    call    _lex
    call    _additive_expr
    call    _popl_ebx
    call    _cmpl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _setge
    call    _al
    call    _nl
    call    _movzbl
    call    _al
    call    _comma
    call    _eax
    call    _nl
    jmp     6b

_additive_expr:
    call    _multiplicative_expr
3:
    call    _lex
    cmpl    $'+, token_tag
    je      1f
    cmpl    $'-, token_tag
    je      2f
    call    _lex_unput
    ret
1:
    call    _pushl_eax
    call    _lex
    call    _multiplicative_expr
    call    _popl_ebx
    call    _addl
    call    _ebx
    call    _comma
    call    _eax
    call    _nl
    jmp     3b
2:
    call    _pushl_eax
    call    _lex
    call    _multiplicative_expr
    call    _movl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _popl_eax
    call    _subl
    call    _ebx
    call    _comma
    call    _eax
    call    _nl
    jmp     3b
    

_multiplicative_expr:
    call    _prefix_expr
4:
    call    _lex
    cmpl    $'*, token_tag
    je      1f
    cmpl    $'/, token_tag
    je      2f
    cmpl    $'%, token_tag
    je      3f
    call    _lex_unput
    ret
1:
    call    _pushl_eax
    call    _lex
    call    _prefix_expr
    call    _popl_ebx
    call    _imul
    call    _ebx
    call    _comma
    call    _eax
    call    _nl
    jmp     4b
2:
    call    _pushl_eax
    call    _lex
    call    _prefix_expr
    /* move eax to ebx */
    call    _movl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _popl_eax
    /* clear edx */
    call    _xorl
    call    _edx
    call    _comma
    call    _edx
    call    _nl

    call    _idiv
    call    _ebx
    call    _nl
    jmp     4b
3:
    call    _pushl_eax
    call    _lex
    call    _prefix_expr
    /* move eax to ebx */
    call    _movl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _popl_eax
    /* clear edx */
    call    _xorl
    call    _edx
    call    _comma
    call    _edx
    call    _nl

    call    _idiv
    call    _ebx
    call    _nl

    call    _movl
    call    _edx
    call    _comma
    call    _eax
    call    _nl
    jmp     4b

_prefix_expr:
    cmpl    $'+, token_tag
    je      1f
    cmpl    $'-, token_tag
    je      2f
    cmpl    $'*, token_tag
    je      3f
    cmpl    $'&, token_tag
    je      4f
    call    _simple_item
    ret
1:
    call    _lex
    call    _simple_item
    ret
2:
    call    _lex
    call    _simple_item
    call    _negl
    call    _eax
    call    _nl
    ret
3:
    subl    $4, %esp
    call    _lex
    call    _simple_item
    call    _movl
    movl    $'(, (%esp)
    call    _putc
    call    _eax
    movl    $'), (%esp)
    call    _putc
    call    _comma
    call    _eax
    call    _nl
    addl    $4, %esp
    ret
4:  /* addressof expr */
    call    _lex
    cmpl    $TOK_IDENT, token_tag
    je      5f
    cmpl    $TOK_PVAR, token_tag
    je      6f
    cmpl    $TOK_XVAR, token_tag
    je      7f
    call    _syntax_error
    ret
5:
    call    _movl
    pushl   $'$
    call    _putc
    movl    $token_text, (%esp)
    call    _puts
    call    _comma
    call    _eax
    call    _nl
    addl    $4, %esp
    ret
6:
    call    _movl
    call    _ebp
    call    _comma
    call    _eax
    call    _nl
    call    _addl
    movl    token_val, %eax
    addl    $2, %eax
    imul    $4, %eax
    pushl   %eax
    call    _integer
    addl    $4, %esp
    call    _comma
    call    _eax
    call    _nl
    ret
7:
    call    _movl
    call    _ebp
    call    _comma
    call    _eax
    call    _nl
    call    _subl
    movl    token_val, %eax
    imul    $4, %eax
    movl    %eax, (%esp)
    call    _integer
    addl    $4, %esp
    call    _comma
    call    _eax
    call    _nl
    ret

_simple_item:
    cmpl    $TOK_IDENT, token_tag
    je      1f
    cmpl    $TOK_XVAR, token_tag
    je      2f
    cmpl    $TOK_PVAR, token_tag
    je      3f
    cmpl    $'(, token_tag
    je      4f
    cmpl    $TOK_RCH, token_tag
    je      12f
    cmpl    $TOK_MACRO, token_tag
    je      13f
    cmpl    $TOK_SYSCALL, token_tag
    je      14f
    call    _constant
    jmp     5f
1:
    pushl   $token_text
    call    _push_ident
    addl    $4, %esp
    call    _lex
    cmpl    $'(, token_tag
    je      10f
    call    _lex_unput
    jmp     11f
2:
    call    _return_xvar
    jmp		5f
3:
    call    _return_pvar
    jmp		5f
4:
    call    _lex
    call    _or_expr
    call    _lex
    pushl   $')
    call    _symbol
    addl    $4, %esp
    jmp     5f
5:
    call    _lex
    cmpl    $'[, token_tag
    je      6f
    cmpl    $'{, token_tag
    je      8f
    cmpl    $'(, token_tag
    je      15f
    call    _lex_unput
    ret
6:
    call    _array_ref
    jmp     5b
8:
    call    _syntax_error
10:
    call    _funcall
    ret
11:
    call    _movl
    pushl   $0
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    addl    $4, %esp
    call    _pop_ident
    call    _comma
    call    _eax
    call    _nl
    jmp     5b
12: /* rdch(ary,idx) -> %al = *(ary+idx) */
    subl    $4, %esp
    call    _lex
    movl    $'(, (%esp)
    call    _symbol
    call    _lex
    call    _or_expr
    call    _pushl_eax
    call    _lex
    movl    $',, (%esp)
    call    _symbol
    call    _lex
    call    _or_expr
    call    _popl_ebx
    call    _addl
    call    _eax
    call    _comma
    call    _ebx
    call    _nl
    call    _lex
    movl    $'), (%esp)
    call    _symbol

    call    _movsbl
    movl    $'(, (%esp)
    call    _putc
    call    _ebx
    movl    $'), (%esp)
    call    _putc
    call    _comma
    call    _eax
    call    _nl

    addl    $4, %esp
    ret
13:
    call    _movl
    pushl   $'$
    call    _putc
    movl    $token_text, (%esp)
    call    _puts
    call    _comma
    call    _eax
    call    _nl
    addl    $4, %esp
    ret
14:
    call    _syscall
    ret
15:
    call    _indcall
    ret

_array_ref:
    subl    $4, %esp
    call    _pushl_eax
    call    _lex
    call    _or_expr
    call    _lex
    movl    $'], (%esp)
    call    _symbol
    call    _popl_ebx
    call    _imul
    movl    $4, (%esp)
    call    _integer
    call    _comma
    call    _eax
    call    _nl

    call    _addl
    call    _ebx
    call    _comma
    call    _eax
    call    _nl

    call    _movl
    movl    $'(, (%esp)
    call    _putc
    call    _eax
    movl    $'), (%esp)
    call    _putc
    call    _comma
    call    _eax
    call    _nl

    addl    $4, %esp
    ret

_funcall:
    subl    $8, %esp
    xorl    %eax, %eax
    movl    %eax, 4(%esp)   /* number of arguments */
    call    _args
    movl    %eax, 4(%esp)   /* store number of arguments */
    cmpl    $0, %eax
    je      1f
    movl    %eax, (%esp)
    call    _push_args
1:
    call    _call
    movl    $0, (%esp)
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    call    _pop_ident
    call    _nl

    movl    4(%esp), %eax
    cmpl    $0, %eax
    je      2f
    /* fix esp */
    call    _addl
    movl    4(%esp), %eax
    imul    $8, %eax
    movl    %eax, (%esp)
    call    _integer
    call    _comma
    call    _esp
    call    _nl
2:
    addl    $8, %esp
    ret

_push_args:
    pushl   %ebp
    movl    %esp, %ebp
    subl    $8, %esp

    /* allocate stack frame */
    call    _subl
    movl    8(%ebp), %eax   /* number of arguments */
    imul    $4, %eax
    movl    %eax, (%esp)
    call    _integer
    call    _comma
    call    _esp
    call    _nl
    /* copy arguments */
    xorl    %eax, %eax
    movl    %eax, -4(%ebp)
1:
    movl    8(%ebp), %eax
    movl    -4(%ebp), %ebx
    cmpl    %eax, %ebx
    je      2f
    subl    $4, %esp
    call    _movl

    movl    8(%ebp), %eax
    imul    $2, %eax
    movl    -4(%ebp), %ebx
    subl    %ebx, %eax
    decl    %eax
    imul    $4, %eax
    movl    %eax, (%esp)
    call    _putnum
    movl    $'(, (%esp)
    call    _putc
    call    _esp
    movl    $'), (%esp)
    call    _putc
    call    _comma
    call    _eax
    call    _nl
    call    _movl
    call    _eax
    call    _comma
    movl    -4(%ebp), %eax
    imul    $4, %eax
    movl    %eax, (%esp)
    call    _putnum
    movl    $'(, (%esp)
    call    _putc
    call    _esp
    movl    $'), (%esp)
    call    _putc
    call    _nl
    addl    $4, %esp
    incl    -4(%ebp)
    jmp     1b
2:
    leave
    ret

_indcall:
    subl    $8, %esp
    call    _pushl_eax      /* address of the function */
    xorl    %eax, %eax
    movl    %eax, 4(%esp)   /* number of arguments */
    call    _args
    movl    %eax, 4(%esp)   /* store number of arguments */
    cmpl    $0, %eax
    je      1f
    movl    %eax, (%esp)
    call    _push_args
1:
    call    _movl
    movl    4(%esp), %eax
    imul    $8, %eax
    movl    %eax, (%esp)
    call    _putnum
    movl    $'(, (%esp)
    call    _putc
    call    _esp
    movl    $'), (%esp)
    call    _putc
    call    _comma
    call    _eax
    call    _nl
    call    _call
    movl    $'*, (%esp)
    call    _putc
    call    _eax
    call    _nl

    movl    4(%esp), %eax
    cmpl    $0, %eax
    je      2f
    /* fix esp */
    call    _addl
    movl    4(%esp), %eax
    imul    $8, %eax
    addl    $4, %eax
    movl    %eax, (%esp)
    call    _integer
    call    _comma
    call    _esp
    call    _nl
2:
    addl    $8, %esp
    ret
    
_return_xvar:
    call    _movl
    pushl   token_val
    call    _xvar
    addl    $4, %esp
    call    _comma
    call    _eax
    call    _nl
    ret

_return_pvar:
    call    _movl
    pushl   token_val
    call    _pvar
    addl    $4, %esp
    call    _comma
    call    _eax
    call    _nl
    ret

_declaration:
    cmpl    $'[, token_tag
    je      1f
    cmpl    $'(, token_tag
    je      2f
    cmpl    $TOK_TINT, token_tag
    je      3f
    cmpl    $TOK_TCHAR, token_tag
    je      4f
    jmp     5f
1:
    call    _enter_data_area
    pushl   $0
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    call    _pop_ident
    movl    $':, (%esp)
    call    _putc
    addl    $4, %esp
    call    _space
    call    _array
    ret
2:
    call    _enter_text_area
    pushl   $0
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    call    _pop_ident
    movl    $':, (%esp)
    call    _putc
    addl    $4, %esp
    call    _nl
    call    _fundecl
    ret
3:
    subl    $8, %esp
    call    _enter_data_area
    movl    $0, (%esp)
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    call    _pop_ident
    movl    $':, (%esp)
    call    _putc
    call    _space
    call    _dot_long
    call    _new_labelid
    movl    %eax, 4(%esp)
    movl    %eax, (%esp)
    call    _label
    call    _nl
    call    _lex
    movl    $'[, (%esp)
    call    _symbol
    call    _dot_comm
    movl    4(%esp), %eax
    movl    %eax, (%esp)
    call    _label
    call    _comma
    call    _lex
    call    _simple_value
    movl    $'*, (%esp)
    call    _putc
    movl    $4, (%esp)
    call    _putnum
    call    _nl
    call    _lex
    movl    $'], (%esp)
    call    _symbol
    addl    $8, %esp
    ret
4:
    subl    $8, %esp
    call    _enter_data_area
    movl    $0, (%esp)
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    call    _pop_ident
    movl    $':, (%esp)
    call    _putc
    call    _space
    call    _dot_long
    call    _new_labelid
    movl    %eax, 4(%esp)
    movl    %eax, (%esp)
    call    _label
    call    _nl
    call    _lex
    movl    $'[, (%esp)
    call    _symbol
    call    _dot_comm
    movl    4(%esp), %eax
    movl    %eax, (%esp)
    call    _label
    call    _comma
    call    _lex
    call    _simple_value
    call    _nl
    call    _lex
    movl    $'], (%esp)
    call    _symbol
    addl    $8, %esp
    ret
5:
    call    _enter_data_area
    pushl   $0
    call    _get_nth_ident
    movl    %eax, (%esp)
    call    _puts
    call    _pop_ident
    movl    $':, (%esp)
    call    _putc
    addl    $4, %esp
    call    _space
    call    _dot_long
    call    _space
    call    _simple_value
    call    _nl
    ret

_array:
    subl    $4, %esp
    call    _space
    call    _dot_long
    call    _space
    call    _new_labelid
    movl    %eax, (%esp)
    call    _label
    call    _nl
    call    _labeldef
    call    _space
    call    _dot_long
    call    _space
    call    _lex
1:
    call    _simple_value
    call    _lex
    cmpl    $'], token_tag
    je      2f
    movl    $',, (%esp)
    call    _symbol
    call    _comma
    call    _lex
    jmp     1b
2:
    call    _nl
    addl    $4, %esp
    ret

_fundecl:
    subl    $8, %esp

    /* parse arguments */
    call    _params

    call    _setebp
    call    _lex
    call    _block
    call    _leave
    call    _nl
    call    _ret
    call    _nl
    addl    $8, %esp
    ret

_params:
    subl    $4, %esp
    movl    $0, (%esp)
    call    _lex
    cmpl    $'), token_tag
    je      3f
1:
    cmpl    $TOK_PVAR, token_tag
    jne     2f
    movl    (%esp), %eax
    cmpl    token_val, %eax
    jne     2f
    call    _lex
    cmpl    $',, %eax
    jne     3f
    incl    (%esp)
    call    _lex
    jmp     1b
2:
    call    _syntax_error
3:
    movl    $'), (%esp)
    call    _symbol
    addl    $4, %esp
    ret

_block:
    subl    $4, %esp
    movl    $'{, (%esp)
    call    _symbol
    call    _lex
1:
    cmpl    $';, token_tag
    jne     2f
    call    _lex
2:
    cmpl    $'}, token_tag
    je      3f
    call    _item
    call    _lex
    cmpl    $';, token_tag
    jne     3f
    call    _lex
    jmp     1b
3:
    movl    $'}, (%esp)
    call    _symbol
    addl    $4, %esp
    ret

_simple_value:
5:
    cmpl    $TOK_INT, token_tag
    je      1f
    cmpl    $TOK_IDENT, token_tag
    je      2f
    cmpl    $TOK_STRING, token_tag
    je      3f
    cmpl    $'-, token_tag
    je      4f
    cmpl    $TOK_MACRO, token_tag
    je      5f
    call    _syntax_error
1:
    pushl   token_val
    call    _putnum
    addl    $4, %esp
    ret
2:
    pushl   $token_text
    call    _puts
    addl    $4, %esp
    ret
3:
    call    _put_string_addr
    pushl   $token_text
    call    _push_string
    addl    $4, %esp
    ret
4:
    pushl   $'-
    call    _putc
    addl    $4, %esp
    call    _lex
    jmp     5b
5:
    subl    $4, %esp
    movl    $token_text, (%esp)
    call    _puts
    addl    $4, %esp
    ret

_constant:
    cmpl    $TOK_INT, token_tag
    je      1f
    cmpl    $TOK_STRING, token_tag
    je      2f
    jmp     3f
1:
    pushl   token_val
    call    _return_int
    addl    $4, %esp
    ret
2:
    call    _return_string
    ret
3:
    call    _syntax_error

_return_int:
    call    _movl
    movl    4(%esp), %eax
    pushl   %eax
    call    _integer
    addl    $4, %esp
    call    _comma
    call    _eax
    call    _nl
    ret

_return_string:
    call    _movl
    pushl   $'$
    call    _putc
    addl    $4, %esp
    call    _put_string_addr
    call    _comma
    call    _eax
    call    _nl
    pushl   $token_text
    call    _push_string
    addl    $4, %esp
    ret
