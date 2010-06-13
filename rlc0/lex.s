/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: lex.s 2010-06-13 13:45:18 nineties $ */

.include "defs.s"
.include "token.s"

/* int _lex(void) :
   Read one token, skips following whitespaces and returns the code of the token.
   If the token has a value, stores it to 'token_val'.
 */

/*
 * regular expressions:
 * spaces     : [\n\r\t ]
 * letter     : [A-Za-z_]
 * digit      : [0-9]
 * integer    : 0|[1-9][0-9]*
 * identifier : {letter}({letter)|{digit})*
 * escape     : \\['"?\\abfnrtv0]
 * character  : \'({escape}|[^\\\'\n])\'
 * string     : \"({escape}|[^\\\"\n])*\"
 * comment    : (% [^"%)"]* %)
 * symbol     : . 
 */

/* character group :
 * CH_NULL      : \0
 * CH_INVALID   : invalid characters
 * CH_SPACES    : [\t\r ]
 * CH_NL        : '\n
 * CH_ZERO      : 0
 * CH_NONZERO   : [1-9]
 * CH_NORMALCH  : [A-Za-z_]/[abfnrtv]
 * CH_SPECIALCH : [abfrtv]
 * CH_N         : n
 * CH_P_OR_X    : p|x
 * CH_SQUOTE    : \'
 * CH_DQUOTE    : \"
 * CH_BACKSLASH : \\
 * CH_QUESTION  : \?
 * CH_SYMBOL    : other characters
 */

.equ CH_NULL,       0
.equ CH_INVALID,    1
.equ CH_SPACES,     2
.equ CH_ZERO,       3
.equ CH_NONZERO,    4
.equ CH_NORMALCH,   5
.equ CH_SPECIALCH,  6
.equ CH_N,          7
.equ CH_SQUOTE,     8
.equ CH_DQUOTE,     9
.equ CH_BACKSLASH,  10
.equ CH_QUESTION,   11
.equ CH_SYMBOL,     12
.equ CH_NL,         13
.equ CH_P_OR_X,     14

.section .rodata
lex_chgroup:
    .long  0,  1,  1,  1,  1,  1,  1,  1,  1,  2, 13,  1,  1,  2,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  2, 12,  9, 12, 12, 12, 12,  8, 12, 12, 12, 12, 12, 12, 12, 12
    .long  3,  4,  4,  4,  4,  4,  4,  4,  4,  4, 12, 12, 12, 12, 12, 11
    .long 12,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
    .long  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5, 12, 10, 12, 12,  5
    .long 12,  6,  6,  5,  5,  5,  6,  5,  5,  5,  5,  5,  5,  5,  7,  5
    .long 14,  5,  6,  5,  6,  5,  6,  5, 14,  5,  5, 12, 12, 12, 12,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
    .long  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1

/*                        
 * state transition diagram:
 *
 * +---+
 * |@n | == accepting state
 * +---+
 *
 * +---+    0      +---+
 * | 0 +--+------->|@1 |
 * +---+  |        +---+
 *        | [1-9]  +---+
 *        +------->|@2 +--+
 *        |        +---+  | [0-9]
 *        |          ^    |
 *        |          +----+
 *        | letter +---+    others        +---+
 *        +------->| 3 +--+-------------->|@17| (detect reserved words here)
 *        |        +---+  |               +---+
 *        |          ^    | letter|digit
 *        |          +----+
 *        | \'     +---+ [^\\\'\n] +---+   \'    +---+
 *        +------->| 4 +---------->| 5 +-------->|@6 |
 *        |        +-+-+           +---+         +---+
 *        |          | +---+ ['"?\\abfnrtv0] +---+ ^
 *        |       \\ +>| 7 +---------------->| 8 +-+ \'
 *        |            +---+                 +---+
 *        | \"       +---+ \"               +---+
 *        +-+------->| 9 +----------------->|@10|
 *        | |        +-+-+                  +---+
 *        | |          |
 *        | +----------+
 *        | |[^\\\"\n] | \\
 *        | |          v
 *        | |        +---+
 *        | +--------+ 11|
 *        |    \     +---+
 *        |  ['"?\\abfnrtv0]
 *        |
 *        |symbol +---+
 *        +------>|@12| (detect == != <= >= => here)
 *        |       +---+
 *        |spaces +---+     +---+
 *        +------>| 13+---->| 0 |
 *        |       +---+     +---+
 *        | \0    +---+
 *        +------>|@14| 
 *        |       +---+
 *        | p|x   +---+ [0-9] +---+  letter +---+
 *        +------>| 19+------>|@20+-+------>| 3 |
 *                +-+-+       +---+ |       +---+
 *                  |letter     ^   |         ^
 *                  |           +---+         |
 *                  +-------------------------+
 *         \0|spaces|     +---+
 *         |symbols +---->|@17|
 *                        +---+
 * error state    : 15
 * finished state : 16
 */

/* jump table */
.section .rodata
/*
 *              N   I   S   Z   N   N   S   N   S   D   B   Q   S   N   P 
 *              U   N   P   E   O   O   P   :   Q   Q   A   U   Y   L   _ 
 *              L   V   A   R   N   R   E   :   U   U   C   E   M   :   O 
 *              L   A   C   O   Z   M   C   :   O   O   K   S   B   :   R 
 *              :   L   E   :   E   A   I   :   T   T   S   T   O   :   _ 
 *              :   I   S   :   R   L   A   :   E   E   L   I   L   :   X 
 *              :   D   :   :   O   C   L   :   :   :   A   O   :   :   : 
 *              :   :   :   :   :   H   C   :   :   :   S   N   :   :   : 
 *              :   :   :   :   :   :   H   :   :   :   H   :   :   :   : 
 */
s0_next:  .long s14,s15,s13, s1, s2, s3, s3, s3, s4, s9,s15,s12,s12,s13,s19
s1_next:  .long s16,s15,s16,s15,s15,s15,s15,s15,s16,s16,s16,s16,s16,s16,s15
s2_next:  .long s16,s15,s16, s2, s2,s15,s15,s15,s16,s16,s16,s16,s16,s16,s15
s3_next:  .long s17,s15,s17, s3, s3, s3, s3, s3,s17,s17,s17,s17,s17,s17, s3
s4_next:  .long s15,s15, s5, s5, s5, s5, s5, s5, s5, s5, s7, s5, s5, s5, s5
s7_next:  .long s15,s15,s15, s8,s15,s15, s8, s8, s8, s8, s8, s8,s15,s15,s15
s9_next:  .long s15,s15, s9, s9, s9, s9, s9, s9, s9,s10,s11, s9, s9, s9, s9
s11_next: .long s15,s15,s15, s9,s15,s15, s9, s9, s9, s9, s9, s9,s15,s15,s15
s19_next: .long s17,s15,s17,s20,s20, s3, s3, s3,s17,s17,s17,s17,s17,s17, s3
s20_next: .long s16,s15,s16,s20,s20, s3, s3, s3,s16,s16,s16,s16,s16,s16, s3

.data

.comm token_text,MAX_TOKEN_LEN,1 
.global token_tag, token_len, token_val
token_tag: .long 0
token_len: .long 0
token_val: .long 0

unputted: .long 0

.global srcline
srcline: .long 1

.equ IDENT_STACK_LEN,16
.comm ident_stack,MAX_TOKEN_LEN*IDENT_STACK_LEN,1
ident_stack_depth: .long 0

.text

.global _push_ident
_push_ident:
    cmpl    $IDENT_STACK_LEN, ident_stack_depth
    je      1f
    movl    4(%esp), %eax
    pushl   %eax
    movl    ident_stack_depth, %eax
    incl    ident_stack_depth
    imul    $MAX_TOKEN_LEN, %eax
    addl    $ident_stack, %eax
    pushl   %eax
    call    _strcpy
    addl    $8, %esp
    ret
1:
    call    _flush
    pushl   output_fd
    pushl   $idstack_overflow
    movl    $STDERR_FD, output_fd
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit

.global _pop_ident
_pop_ident:
    cmpl    $0, ident_stack_depth
    je      1f
    decl    ident_stack_depth
    ret
1:
    call    _flush
    pushl   output_fd
    pushl   $idstack_empty
    movl    $STDERR_FD, output_fd
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit

.global _get_nth_ident
_get_nth_ident:
    movl    4(%esp), %ebx
    cmpl    ident_stack_depth, %ebx
    jae     1f
    movl    ident_stack_depth, %eax
    subl    %ebx, %eax
    decl    %eax
    imul    $MAX_TOKEN_LEN, %eax
    addl    $ident_stack, %eax
    ret
1:
    call    _flush
    pushl   output_fd
    pushl   $idstack_overflow
    movl    $STDERR_FD, output_fd
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit

.section .rodata
idstack_overflow: .string "ERROR: Identifier stack overflow\n"
idstack_empty:    .string "INTERNAL ERROR: Identifier stack is empty\n"
.text

_undefined_token:
    call    _flush
    pushl   output_fd
    movl    $STDERR_FD, output_fd
    pushl   srcline
    call    _putnum
    movl    $':, (%esp)
    call    _putc
    movl    $undef_msg, (%esp)
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit
_too_long_token:
    call    _flush
    pushl   output_fd
    movl    $STDERR_FD, output_fd
    pushl   srcline
    call    _putnum
    movl    $':, (%esp)
    call    _putc
    movl    $toolong_msg, (%esp)
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit
_unterminated_comment:
    call    _flush
    pushl   output_fd
    movl    $STDERR_FD, output_fd
    pushl   srcline
    call    _putnum
    movl    $':, (%esp)
    call    _putc
    movl    $unterminated_msg, (%esp)
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit
.section .rodata
undef_msg:   .string "ERROR: undefined token\n"
toolong_msg: .string "ERROR: too long token\n"
unterminated_msg: .string "ERROR: unterminated comment\n"
.text

_lex_lookahead:
    call    _nextc
    cmpl    $EOF, %eax
    je      1f
    movl    lex_chgroup(,%eax,4), %eax
    ret
1:
    movl    $CH_NULL, %eax
    ret

_lex_consume:
    call    _getc
    cmpb    $'\n, %al
    jne     1f
    incl    srcline
1:
    movl    token_len, %ebx
    cmpl    $MAX_TOKEN_LEN-1, %ebx
    jae     2f
    movb    %al, token_text(%ebx)
    addl    $1, %ebx
    movb    $0, token_text(%ebx)  /* \0 */
    movl    %ebx, token_len
    ret
2:
    call    _too_long_token

_lex_skip:
    call    _getc
    cmpb    $'\n, %al
    jne     1f
    incl    srcline
1:
    ret

.section .rodata
/* values of escaped sequences (begins from \") */
ch2esc:
    /*    \"              \'                         \0                        */
    .long 34, 0, 0, 0, 0, 39, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    /*                      \?                                                 */
    .long 0, 0, 0, 0, 0, 0, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    /*                                     \\             \a \b           \f   */
    .long 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 92, 0, 0, 0, 0, 7, 8, 0, 0, 0, 12, 0
    /*                      \n           \r    \t     \v                       */
    .long 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 13, 0, 9, 0, 11

/* reserved words */
reserved_words:
    .long if_text, else_text, while_text, goto_text, label_text, return_text, syscall_text, export_text, allocate_text, include_text, wch_text, rch_text, int_text, char_text, 0
if_text:       .string "if"
else_text:     .string "else"
while_text:    .string "while"
goto_text:     .string "goto"
label_text:    .string "label"
return_text:   .string "return"
syscall_text:  .string "syscall"
export_text:   .string "export"
allocate_text: .string "allocate"
include_text:  .string "include"
wch_text:      .string "wch"
rch_text:      .string "rch"
int_text:      .string "int"
char_text:     .string "char"
.text

.global _lex_unput
_lex_unput:
    cmpl    $0, unputted
    jne     1f
    movl    $1, unputted
    ret
1:
    subl    $4, %esp
    movl    $unput_errmsg, (%esp)
    call    _puts
    movl    $1, (%esp)
    call    _exit

.section .rodata
unput_errmsg: .string "ERROR: try to unput two or more tokens\n"
.text

.global _lex
_lex:
    pushl   %ebp
    movl    %esp, %ebp
    cmpl    $1, unputted
    je      ret_unputted
s0:
    movl    $0, token_len
    movl    $0, token_val
    call    _lex_lookahead
    movl    s0_next(,%eax,4), %eax
    jmp     *%eax
s1:
    call    _lex_consume
    call    _lex_lookahead
    movl    $TOK_INT, token_tag
    movl    s1_next(,%eax,4), %eax
    movl    $0, token_val
    jmp     *%eax
s2:
    call    _lex_consume
    subl    $'0, %eax       /* convert to value */ 
    movl    token_val, %ebx
    imul    $10, %ebx
    addl    %ebx, %eax
    movl    %eax, token_val
    call    _lex_lookahead
    movl    $TOK_INT, token_tag
    movl    s2_next(,%eax,4), %eax
    jmp     *%eax
s3:
    call    _lex_consume
    call    _lex_lookahead
    movl    $TOK_IDENT, token_tag
    movl    s3_next(,%eax,4), %eax
    jmp     *%eax
s4:
    call    _lex_consume
    call    _lex_lookahead
    movl    s4_next(,%eax,4), %eax
    jmp     *%eax
s5:
    call    _lex_consume
    movl    %eax, token_val
    call    _lex_lookahead
    cmpl    $CH_SQUOTE, %eax
    jne     s15
    jmp     s6
s6:
    call    _lex_consume
    movl    $TOK_INT, token_tag
    jmp     s16
s7:
    call    _lex_consume
    call    _lex_lookahead
    movl    s7_next(,%eax,4), %eax
    jmp     *%eax
s8:
    call    _lex_consume
    subl    $'\", %eax
    movl    ch2esc(,%eax,4), %eax
    movl    %eax, token_val
    call    _lex_lookahead
    cmpl    $CH_SQUOTE, %eax
    je      s6
    jmp     s15
s9:
    call    _lex_consume
    call    _lex_lookahead
    movl    s9_next(,%eax,4), %eax
    jmp     *%eax
s10:
    call    _lex_consume
    movl    $TOK_STRING, token_tag
    jmp     s16
s11:
    call    _lex_consume
    call    _lex_lookahead
    movl    s11_next(,%eax,4), %eax
    jmp     *%eax
s12:
    call    _lex_consume
    movl    %eax, token_tag
    cmpl    $'=, %eax
    je      1f
    cmpl    $'!, %eax
    je      2f
    cmpl    $'<, %eax
    je      3f
    cmpl    $'>, %eax
    je      4f
    cmpl    $'(, %eax
    je      7f
    jmp     s16
1:
    call    _nextc
    cmpl    $'=, %eax
    je      5f
    cmpl    $'>, %eax
    je      6f
    jmp     s16
5:
    call    _lex_consume
    movl    $TOK_EQ, token_tag
    jmp     s16
6:
    call    _lex_consume
    movl    $TOK_DARROW, token_tag
    jmp     s16
2:
    call    _nextc
    cmpl    $'=, %eax
    jne     s16
    call    _lex_consume
    movl    $TOK_NE, token_tag
    jmp     s16
3:
    call    _nextc
    cmpl    $'=, %eax
    jne     s16
    call    _lex_consume
    movl    $TOK_LE, token_tag
    jmp     s16
4:
    call    _nextc
    cmpl    $'=, %eax
    jne     s16
    call    _lex_consume
    movl    $TOK_GE, token_tag
    jmp     s16
7:
    call    _nextc
    cmpl    $'%, %eax
    jne     s16
    /* comment block */
    call    _lex_skip
    jmp     8f
8:
    call    _nextc
    cmpl    $EOF, %eax
    je      11f
    cmpl    $'%, %eax
    je      9f
    call    _lex_skip
    jmp     8b
9:
    call    _lex_skip
    call    _nextc
    cmpl    $'), %eax
    je      10f
    cmpl    $'%, %eax
    je      9b
    cmpl    $EOF, %eax
    je      11f
    call    _lex_skip
    jmp     8b
10:
    call    _lex_skip
    call    _nextc
    cmpl    $';, %eax
    jne     s11
    call    _lex_skip
    jmp     s0
11:
    call    _unterminated_comment
s13:
    cmpl    $CH_NL, %eax
    call    _lex_consume
    jmp     s0
s14:
    movl    $TOK_END, token_tag
    jmp     s16
s15:
    call    _undefined_token
s16:
    call    _check_macro
    leave
    ret
s17:
    subl    $12, %esp
    movl    $token_text, (%esp)
    xorl    %eax, %eax
    movl    %eax, 8(%esp)
1:
    movl    8(%esp), %eax
    movl    reserved_words(,%eax,4), %eax
    cmpl    $0, %eax
    je      2f
    movl    %eax, 4(%esp)
    call    _strcmp
    cmpl    $1, %eax
    je      3f
    incl    8(%esp)
    jmp     1b
2:
    addl    $12, %esp
    movl    $TOK_IDENT, token_tag
    jmp     s16
3:
    movl    8(%esp), %eax
    addl    $RESERVED_WORDS_ID_BEGIN, %eax
    movl    %eax, token_tag
    addl    $12, %esp
    jmp     s16
s18:
    call    _lex_consume
    call    _lex_lookahead
    cmpl    $CH_NL, %eax
    je      s0
    cmpl    $CH_NULL, %eax
    je      s0
    jmp     s18
s19:
    call    _lex_consume
    cmpb    $'p, %al
    je      1f
    movl    $TOK_XVAR, token_tag
    jmp     2f
1:
    movl    $TOK_PVAR, token_tag
2:
    movl    $0, token_val
    call    _lex_lookahead
    movl    s19_next(,%eax,4), %eax
    jmp     *%eax
s20:
    call    _lex_consume
    subl    $'0, %eax
    movl    token_val, %ebx
    imul    $10, %ebx
    addl    %ebx, %eax
    movl    %eax, token_val
    call    _lex_lookahead
    movl    s20_next(,%eax,4), %eax
    jmp     *%eax
ret_unputted:
    movl    token_tag, %eax
    movl    $0, unputted
    leave
    ret

_check_macro:
    cmpl    $TOK_IDENT, token_tag
    jne     1f
    movl    $token_text, %ebx
    movb    (%ebx), %al
    cmpb    $'Z, %al
    ja      1f
    movl    $TOK_MACRO, token_tag
1:
    ret

.global _print_current_token
_print_current_token:
    pushl   %ebp
    movl    %esp, %ebp
    subl    $4, %esp
    movl    8(%ebp), %eax   /* token type */
    cmpl    $256, %eax
    jb      1f
    subl    $256, %eax
    movl    tag_names(,%eax,4), %eax
    movl    %eax, (%esp)
    call    _puts
    movl    $' , (%esp)
    call    _putc
    movl    $token_text, (%esp)
    call    _puts
    leave
    ret
1:
    movl    $symbol, (%esp)
    call    _puts
    movl    $' , (%esp)
    call    _putc
    movl    $token_text, (%esp)
    call    _puts
    leave
    ret

.section .rodata
tag_names:
    .long tag0,tag1,tag2,tag3,tag4,tag5,tag6,tag7,tag8,tag9,tag10,tag11,tag12,tag13,tag14,tag15,tag16,tag17,tag18,tag19,tag20,tag21,tag22,tag23,tag24,tag25
tag0:   .string "INT"
tag1:   .string "STRING"
tag2:   .string "IDENT"
tag3:   .string "MACRO"
tag4:   .string "XVAR"
tag5:   .string "PVAR"
tag6:   .string "IF"
tag7:   .string "ELSE"
tag8:   .string "WHILE"
tag9:   .string "GOTO"
tag10:  .string "LABEL"
tag11:  .string "RETURN"
tag12:  .string "SYSCALL"
tag13:  .string "EXPORT"
tag14:  .string "ALLOCATE"
tag15:  .string "INCLUDE"
tag16:  .string "WCH"
tag17:  .string "RCH"
tag18:  .string "TINT"
tag19:  .string "TCHAR"
tag20:  .string "=="
tag21:  .string "!="
tag22:  .string "<="
tag23:  .string ">="
tag24:  .string "=>"
tag25:  .string "END"
symbol: .string "SYMBOL"
