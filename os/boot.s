/*
 * rowlOS -
 * Copyright (C) 2010 nineties
 *
 * $Id: boot.s 2010-03-23 15:46:25 nineties $
 */

.code16
.equ VIDEOMEM, 0xb800

    jmp entry

entry:
    movw    %cs, %ax
    movw    %ax, %ds
    movw    $VIDEOMEM, %ax
    movw    %ax, %es
    movw    $0, %di
    movb    $' , %al
    movb    $0x06, %ah
    movw    $0x7ff, %cx

paint_back:
    movw    %ax, %es:(%di)
    addw    $2, %di
    decw    %cx
    jnz     paint_back

    movl    $0, %edi
put_msg:
    movb    msg(%edi), %al
    cmpb    $0, %al
    je      fin
    movb    $0x06, %ah
    movw    %ax, %es:(,%edi,2)
    incl    %edi
    jmp     put_msg

fin:
    hlt
    jmp     fin

msg:
    .string  "hello, rowlOS"

    .org    0x1fe
    .byte   0x55,0xaa
