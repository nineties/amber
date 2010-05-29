" Language:	rowl-core
" Maintainer:	nineties <nineties48@gmail.com>
" $Id: rowlcore.vim 2010-05-30 01:42:31 nineties $

if exists("b:current_syntax")
    finish
endif

syn case match

syn keyword rowlcoreConstant  nil true
syn keyword rowlcoreSymbol    do if cond while for foreach set var
syn keyword rowlcoreExternal  import define rewrite
syn match rowlcoreIdentifier  /\<\h\w*/
syn match rowlcoreInteger     /-\?\(0\o*\|[1-9]\d*\|0x\x\+\)\>/
syn match rowlcoreReal        /-\?\d*\.\d\+\>/
syn match rowlcoreEscape      /\\['"?\\abfnrtv0]/ contained
syn match rowlcoreCharacter   /'\(\\["?\\abfnrtv0]\|[^\\\n]\)'/ contains=rowlcoreEscape
syn match rowlcoreString      /"\(\\['"?\\abfnrtv0]\|[^\\\"\n]\)*"/ contains=rowlcoreEscape
syn keyword rowlcoreTodo TODO FIXME NOTE XXX contained
syn region  rowlcoreString start=/"/ skip=/\\"/ end=/"/
syn region  rowlcoreComment start=/;/ end=/\n/ contains=rowlcoreComment,rowlcoreTodo

syn match rowlcoreOperator "\<+\>"
syn match rowlcoreOperator "\<-\>"
syn match rowlcoreOperator "\<*\>"
syn match rowlcoreOperator "\</\>"
syn match rowlcoreOperator "\<%\>"
syn match rowlcoreOperator "\<<<\>"
syn match rowlcoreOperator "\<>>\>"
syn match rowlcoreOperator "\<<\>"
syn match rowlcoreOperator "\<>\>"
syn match rowlcoreOperator "\<<=\>"
syn match rowlcoreOperator "\<>=\>"
syn match rowlcoreOperator "\<==\>"
syn match rowlcoreOperator "\<!=\>"

hi def link rowlcoreComment   Comment
hi def link rowlcoreCharacter Character
hi def link rowlcoreEscape    SpecialChar
hi def link rowlcoreOperator  Operator
hi def link rowlcoreString    String
hi def link rowlcoreInteger   Number
hi def link rowlcoreReal      Number
hi def link rowlcoreSymbol    Statement
hi def link rowlcoreExternal  PreProc
hi def link rowlcoreTodo      Keyword
hi def link rowlcoreConstant  Constant

let b:current_syntax = "rowlcore"

" vim: ts=8
