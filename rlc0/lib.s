/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: lib.s 2010-03-26 20:26:54 nineties $ */

.include "defs.s"

/* system calls */
.equ SYS_EXIT,  1
.equ SYS_READ,  3
.equ SYS_WRITE, 4

.equ RDBUFSZ,512
.equ WRBUFSZ,512

.data

.global output_fd
output_fd: .long STDOUT_FD

/* IO buffers */
.comm  rdbuf,RDBUFSZ,1
rdbuf_beg: .long 0
rdbuf_end: .long 0

.comm  wrbuf,WRBUFSZ,1
wrbuf_idx: .long 0

.text

/* void _flush(void); */
.global _flush
_flush:
    pushl   %ebp
    movl    %esp, %ebp
    cmpl    $0, wrbuf_idx
    je      1f    /* wrbuf is empty */
    movl    $SYS_WRITE, %eax
    movl    output_fd, %ebx
    movl    $wrbuf, %ecx
    movl    wrbuf_idx, %edx
    int     $0x80
    movl    $0, wrbuf_idx
1:
    popl    %ebp
    ret

/* int _getc(void); */
.global _getc
_getc:
    pushl   %ebp
    movl    %esp, %ebp
    movl    rdbuf_beg, %ebx
    cmpl    %ebx, rdbuf_end
    jne     1f
    movl    $0, rdbuf_beg
    movl    $0, rdbuf_end
    movl    $SYS_READ, %eax
    movl    $STDIN_FD, %ebx
    movl    $rdbuf, %ecx
    movl    $RDBUFSZ, %edx
    int     $0x80
    cmpl    $0, %eax      /* check EOF or error */
    jbe     2f
    movl    %eax, rdbuf_end
1:
    xorl    %eax, %eax
    movb    rdbuf(%ebx), %al    /* rdbuf[rdbuf_beg] */
    leal    1(%ebx), %ebx
    movl    %ebx, rdbuf_beg
    popl    %ebp
    ret
2:  /* EOF or error */
    movl    $EOF, %eax
    popl    %ebp
    ret

/* int _nextc(void); 
   Looks ahead next character in rdbuf.
 */
.global _nextc
_nextc:
    push    %ebp
    movl    %esp, %ebp
    movl    rdbuf_beg, %ebx
    cmpl    %ebx, rdbuf_end
    jne     1f
    movl    $0, rdbuf_beg
    movl    $0, rdbuf_end
    movl    $SYS_READ, %eax
    movl    $STDIN_FD, %ebx
    movl    $rdbuf, %ecx
    movl    $RDBUFSZ, %edx
    int     $0x80
    cmpl    $0, %eax      /* check EOF or error */
    jbe     2f
    movl    %eax, rdbuf_end
1:
    xorl    %eax, %eax
    movb    rdbuf(%ebx), %al
    leave
    ret
2:  /* EOF or error */
    movl    $EOF, %eax
    leave
    ret

/* int _putc(int c); */
.global _putc
_putc:
    pushl   %ebp
    movl    %esp, %ebp
    movl    8(%ebp), %eax     /* %eax = c */
    movl    wrbuf_idx, %ebx
    movl    %eax, wrbuf(%ebx) /* wrbuf[wrbuf_idx] = c */
    leal    1(%ebx), %ebx
    movl    %ebx, wrbuf_idx 
    cmpl    $WRBUFSZ, %ebx
    je      1f
    cmpb    $'\n, %al
    je      1f
    jmp     2f
1:
    call    _flush
2:
    leave
    ret

/* void _puts(const char *str); */
.global _puts
_puts:
    pushl   %ebp
    movl    %esp, %ebp
    subl    $16, %esp
    movl    8(%ebp), %ebx   /* %ebx = str */
1:
    movb    (%ebx), %cl
    cmpb    $0, %cl
    je      2f
    movl    %ebx, -4(%ebp)
    pushl   %ecx
    call    _putc
    addl    $4, %esp
    movl    -4(%ebp), %ebx
    addl    $1, %ebx
    jmp     1b
2:
    leave
    ret

/* 32bit decimal integers are less than 11 digits */
.comm putnum_digits,10,1
/* void _putnum(int x) */
.global _putnum
_putnum:
    pushl   %ebp
    movl    %esp, %ebp
    subl    $16, %esp
    xorl    %ecx, %ecx
    movl    8(%ebp), %eax
1:
    xorl    %edx, %edx
    movl    $10, %ebx
    idiv    %ebx    /* %edx = %eax%10, %eax = %eax/10 */
    movb    %dl, putnum_digits(%ecx)
    incl    %ecx
    cmpl    $0, %eax
    jne     1b
2:
    decl    %ecx
    movl    %ecx, -4(%ebp)
    xorl    %eax, %eax
    movb    putnum_digits(%ecx), %al
    addl    $'0, %eax
    pushl   %eax
    call    _putc
    addl    $4, %esp
    movl    -4(%ebp), %ecx
    cmpl    $0, %ecx
    jne     2b
    leave
    ret

.global _strlen
_strlen:
    xorl    %eax, %eax
    movl    4(%esp), %ebx
1:
    movb    (%ebx), %cl
    cmpb    $0, %cl
    je      2f
    incl    %ebx
    incl    %eax
    jmp     1b
2:
    ret

.global _strcpy
_strcpy:
    pushl   %ebp
    movl    %esp, %ebp
    movl    8(%ebp), %eax
    movl    12(%ebp), %ebx
1:
    movb    (%ebx), %cl
    movb    %cl, (%eax)
    cmpb    $0, %cl
    je      2f
    incl    %eax
    incl    %ebx
    jmp     1b
2:
    leave
    ret

.global _strcmp
_strcmp:
    pushl   %ebp
    movl    %esp, %ebp
    movl    8(%ebp), %eax
    movl    12(%ebp), %ebx
1:
    movb    (%eax), %cl
    movb    (%ebx), %dl
    cmpb    %cl, %dl
    jne     2f
    cmpb    $0, %cl
    je      3f
    incl    %eax
    incl    %ebx
    jmp     1b
2:
    movl    $0, %eax
    leave
    ret
3:
    movl    $1, %eax
    leave
    ret


/* void _exit(int status); */
.global _exit
_exit:
    pushl   %ebp
    movl    %esp, %ebp
    call    _flush
    movl    $SYS_EXIT, %eax
    movl    8(%esp), %ebx
    int     $0x80
    ret
