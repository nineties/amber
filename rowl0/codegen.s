/*
 * rowl - generation 0
 * Copyright (C) 2009 nineties
 */

/* $Id: codegen.s 2010-06-13 13:59:33 nineties $ */

.include "defs.s"
.include "token.s"

.data

.set DATA_AREA,0
.set RODATA_AREA,1
.set TEXT_AREA,2

area: .long TEXT_AREA

label_idgen: .long 0

.text

.globl _new_labelid
_new_labelid:
    movl    label_idgen, %eax
    incl    label_idgen
    ret

_change_area:
    movl    4(%esp), %eax
    cmpl    area,%eax
    je      1f
    movl    %eax, area
    movl    area_text(,%eax,4), %eax
    pushl   %eax
    call    _puts
    addl    $4, %esp
1:
    ret

.globl _enter_data_area, _enter_rodata_area, _enter_text_area
_enter_data_area:
    pushl   $DATA_AREA
    call    _change_area
    addl    $4, %esp
    ret

_enter_rodata_area:
    pushl   $RODATA_AREA
    call    _change_area
    addl    $4, %esp
    ret

_enter_text_area:
    pushl    $TEXT_AREA
    call    _change_area
    addl    $4, %esp
    ret



.const_data
area_text: .long data_text, rodata_text, text_text
data_text:    .asciz ".data\n"
rodata_text:  .asciz ".const_data\n"
text_text:    .asciz ".text\n"
global_text:  .asciz ".globl "
comm_text:    .asciz ".comm "
long_text:    .asciz ".long "
string_text:  .asciz ".asciz "
equ_text:     .asciz ".set "
include_text: .asciz ".include "
ret_text:     .asciz "\tret"
movb_text:    .asciz "\tmovb "
movl_text:    .asciz "\tmovl "
leal_text:	  .asciz "\tleal "
pushl_text:   .asciz "\tpushl "
popl_text:    .asciz "\tpopl "
leave_text:   .asciz "\tleave"
sysenter_text: .asciz "\tsysenter "
addl_text:    .asciz "\taddl "
subl_text:    .asciz "\tsubl "
imul_text:    .asciz "\timul "
idiv_text:    .asciz "\tidiv "
negl_text:    .asciz "\tnegl "
shrl_text:    .asciz "\tshrl "
andl_text:    .asciz "\tandl "
orl_text:     .asciz "\torl "
xorl_text:    .asciz "\txorl "
notl_text:    .asciz "\tnotl "
call_text:    .asciz "\tcall "
cmpl_text:    .asciz "\tcmpl "
jmp_text:     .asciz "\tjmp "
je_text:      .asciz "\tje "
pushf_text:   .asciz "\tpushf"
incl_text:    .asciz "\tincl "
decl_text:    .asciz "\tdecl "
setg_text:    .asciz "\tsetg "
setge_text:   .asciz "\tsetge "
setl_text:    .asciz "\tsetl "
setle_text:   .asciz "\tsetle "
sete_text:    .asciz "\tsete "
setne_text:   .asciz "\tsetne "
movzbl_text:  .asciz "\tmovzbl "
movsbl_text:  .asciz "\tmovsbl "
al_text:      .asciz "%al"
eax_text:     .asciz "%eax"
ebx_text:     .asciz "%ebx"
ecx_text:     .asciz "%ecx"
edx_text:     .asciz "%edx"
esi_text:     .asciz "%esi"
edi_text:     .asciz "%edi"
esp_text:     .asciz "%esp"
ebp_text:     .asciz "%ebp"
lbl_text:     .asciz "_lbl"
.text

.globl _symbol
_symbol:
    movl    4(%esp), %eax
    cmpl    %eax, token_tag
    jne     1f
    ret
1:
    call    _syntax_error

.globl _ident
_ident:
    cmpl    $TOK_IDENT, token_tag
    jne     1f
    ret
1:
    call    _syntax_error

.globl _syntax_error
_syntax_error:
    call    _flush
    pushl   output_fd
    movl    $STDERR_FD, output_fd
    pushl   srcline
    call    _putnum
    movl    $':, (%esp)
    call    _putc
    movl    $errmsg, (%esp)
    call    _puts
    call    _flush
    addl    $4, %esp
    popl    output_fd
    pushl   $1
    call    _exit
.const_data
errmsg: .asciz "ERROR: syntax error\n"
.text

_put_pushl:
    subl    $4, %esp
    movl    $pushl_text, (%esp)
    call    _puts
    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _puts
    call    _nl
    addl    $4, %esp
    ret

_put_popl:
    subl    $4, %esp
    movl    $popl_text, (%esp)
    call    _puts
    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _puts
    call    _nl
    addl    $4, %esp
    ret

.globl _pushl_eax, _pushl_ebx, _pushl_ecx, _pushl_edx, _pushl_esi, _pushl_edi, _pushl_ebp
_pushl_eax:
    pushl   $eax_text
    call    _put_pushl
    addl    $4, %esp
    ret

_pushl_ebx:
    pushl   $ebx_text
    call    _put_pushl
    addl    $4, %esp
    ret

_pushl_ecx:
    pushl   $ecx_text
    call    _put_pushl
    addl    $4, %esp
    ret

_pushl_edx:
    pushl   $edx_text
    call    _put_pushl
    addl    $4, %esp
    ret

_pushl_esi:
    pushl   $esi_text
    call    _put_pushl
    addl    $4, %esp
    ret

_pushl_edi:
    pushl   $edi_text
    call    _put_pushl
    addl    $4, %esp
    ret

_pushl_ebp:
    pushl   $ebp_text
    call    _put_pushl
    addl    $4, %esp
    ret

.globl _popl_eax, _popl_ebx, _popl_ecx, _popl_edx, _popl_esi, _popl_edi, _popl_ebp
_popl_eax:
    pushl   $eax_text
    call    _put_popl
    addl    $4, %esp
    ret

_popl_ebx:
    pushl   $ebx_text
    call    _put_popl
    addl    $4, %esp
    ret

_popl_ecx:
    pushl   $ecx_text
    call    _put_popl
    addl    $4, %esp
    ret

_popl_edx:
    pushl   $edx_text
    call    _put_popl
    addl    $4, %esp
    ret

_popl_esi:
    pushl   $esi_text
    call    _put_popl
    addl    $4, %esp
    ret

_popl_edi:
    pushl   $edi_text
    call    _put_popl
    addl    $4, %esp
    ret

_popl_ebp:
    pushl   $ebp_text
    call    _put_popl
    addl    $4, %esp
    ret

/* instructions */ 
.globl _movb, _movl, _leal, _addl, _subl, _imul, _idiv, _andl, _orl, _xorl, _notl, _negl, _shrl, _jmp, _je, _cmpl, _call, _ret, _pushl, _popl, _leave, _sysenter, _pushf, _incl, _decl, _setg, _setg, _setge, _setl, _setle, _sete, _setne, _movzbl, _movsbl
_movb:
    pushl   $movb_text
    call    _puts
    addl    $4, %esp
    ret

_movl:
    pushl   $movl_text
    call    _puts
    addl    $4, %esp
    ret

_leal:
    pushl   $leal_text
    call    _puts
    addl    $4, %esp
    ret

_addl:
    pushl   $addl_text
    call    _puts
    addl    $4, %esp
    ret

_subl:
    pushl   $subl_text
    call    _puts
    addl    $4, %esp
    ret

_imul:
    pushl   $imul_text
    call    _puts
    addl    $4, %esp
    ret

_idiv:
    pushl   $idiv_text
    call    _puts
    addl    $4, %esp
    ret

_negl:
    pushl   $negl_text
    call    _puts
    addl    $4, %esp
    ret

_shrl:
    pushl   $shrl_text
    call    _puts
    addl    $4, %esp
    ret

_andl:
    pushl   $andl_text
    call    _puts
    addl    $4, %esp
    ret

_xorl:
    pushl   $xorl_text
    call    _puts
    addl    $4, %esp
    ret
    
_orl:
    pushl   $orl_text
    call    _puts
    addl    $4, %esp
    ret

_notl:
    pushl   $notl_text
    call    _puts
    addl    $4, %esp
    ret

_jmp:
    pushl   $jmp_text
    call    _puts
    addl    $4, %esp
    ret

_je:
    pushl   $je_text
    call    _puts
    addl    $4, %esp
    ret

_cmpl:
    pushl   $cmpl_text
    call    _puts
    addl    $4, %esp
    ret

_call:
    pushl   $call_text
    call    _puts
    addl    $4, %esp
    ret

_ret:
    pushl   $ret_text
    call    _puts
    addl    $4, %esp
    ret

_pushl:
    pushl   $pushl_text
    call    _puts
    addl    $4, %esp
    ret

_popl:
    pushl   $popl_text
    call    _puts
    addl    $4, %esp
    ret

_leave:
    pushl   $leave_text
    call    _puts
    addl    $4, %esp
    ret

_sysenter:
    pushl   $sysenter_text
    call    _puts
    addl    $4, %esp
    ret

_pushf:
    pushl   $pushf_text
    call    _puts
    addl    $4, %esp
    ret

_incl:
    pushl   $incl_text
    call    _puts
    addl    $4, %esp
    ret

_decl:
    pushl   $decl_text
    call    _puts
    addl    $4, %esp
    ret

_setg:
    pushl   $setg_text
    call    _puts
    addl    $4, %esp
    ret

_setge:
    pushl   $setge_text
    call    _puts
    addl    $4, %esp
    ret

_setl:
    pushl   $setl_text
    call    _puts
    addl    $4, %esp
    ret

_setle:
    pushl   $setle_text
    call    _puts
    addl    $4, %esp
    ret

_sete:
    pushl   $sete_text
    call    _puts
    addl    $4, %esp
    ret

_setne:
    pushl   $setne_text
    call    _puts
    addl    $4, %esp
    ret

_movzbl:
    pushl   $movzbl_text
    call    _puts
    addl    $4, %esp
    ret
_movsbl:
    pushl   $movsbl_text
    call    _puts
    addl    $4, %esp
    ret

/* registers */
.globl _al, _eax, _ebx, _ecx, _edx, _esp, _ebp, _setebp
_al:
    pushl   $al_text
    call    _puts
    addl    $4, %esp
    ret

_eax:
    pushl   $eax_text
    call    _puts
    addl    $4, %esp
    ret

_ebx:
    pushl   $ebx_text
    call    _puts
    addl    $4, %esp
    ret

_ecx:
    pushl   $ecx_text
    call    _puts
    addl    $4, %esp
    ret

_edx:
    pushl   $edx_text
    call    _puts
    addl    $4, %esp
    ret

_esp:
    pushl   $esp_text
    call    _puts
    addl    $4, %esp
    ret

_ebp:
    pushl   $ebp_text
    call    _puts
    addl    $4, %esp
    ret

_setebp:
    call    _pushl
    call    _ebp
    call    _nl
    call    _movl
    call    _esp
    call    _comma
    call    _ebp
    call    _nl
    ret
    
/* variables */
.globl _xvar, _pvar
_xvar:
    subl    $4, %esp
    movl    $'-, (%esp)
    call    _putc
    movl    8(%esp), %eax
    incl    %eax
    imul    $4, %eax
    movl    %eax, (%esp)
    call    _putnum
    movl    $'(, (%esp)
    call    _putc
    call    _ebp
    movl    $'), (%esp)
    call    _putc
    addl    $4, %esp
    ret

_pvar:
    subl    $4, %esp
    movl    8(%esp), %eax
    addl    $2, %eax
    imul    $4, %eax
    movl    %eax, (%esp)
    call    _putnum
    movl    $'(, (%esp)
    call    _putc
    call    _ebp
    movl    $'), (%esp)
    call    _putc
    addl    $4, %esp
    ret

/* constants */
.globl _integer
_integer:
    pushl   $'$
    call    _putc
    addl    $4, %esp
    movl    4(%esp), %eax
    pushl   %eax
    call    _putnum
    addl    $4, %esp
    ret

/* others */
.globl _label, _labeldef, _labeladdr
_label:
    subl    $4, %esp
    movl    $lbl_text, (%esp)
    call    _puts
    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _putnum
    addl    $4, %esp
    ret

_labeldef:
    subl    $4, %esp
    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _label
    movl    $':, (%esp)
    call    _putc
    addl    $4, %esp
    ret

_labeladdr:
    subl    $4, %esp
    movl    $'$, (%esp)
    call    _putc
    movl    8(%esp), %eax
    movl    %eax, (%esp)
    call    _label
    addl    $4, %esp
    ret

.globl _dot_long, _dot_string, _dot_global, _dot_comm, _dot_equ, _dot_include
_dot_long:
    pushl   $long_text
    call    _puts
    addl    $4, %esp
    ret

_dot_string:
    pushl   $string_text
    call    _puts
    addl    $4, %esp
    ret

_dot_global:
    pushl   $global_text
    call    _puts
    addl    $4, %esp
    ret

_dot_comm:
    pushl   $comm_text
    call    _puts
    addl    $4, %esp
    ret

_dot_equ:
    pushl   $equ_text
    call    _puts
    addl    $4, %esp
    ret

_dot_include:
    pushl   $include_text
    call    _puts
    addl    $4, %esp
    ret

.globl _comma, _space, _tab, _nl
_comma:
    pushl   $',
    call    _putc
    addl    $4, %esp
    ret

_space:
    pushl   $' 
    call    _putc
    addl    $4, %esp
    ret

_tab:
    pushl   $0x09
    call    _putc
    addl    $4, %esp
    ret

_nl:
    pushl   $0x0a
    call    _putc
    addl    $4, %esp
    ret
