" Language:	Rowl
" Maintainer:	nineties <nineties48@gmail.com>
" $Id: rowl.vim 2011-10-19 20:46:39 nineties $

if exists("b:current_syntax")
"    finish
endif

syn case match " case sensitive

syn keyword rowlConstant    true false
syn keyword rowlStatement   return import
syn keyword rowlConditional if else
syn keyword rowlRepeat      while

syn match   rowlStandardConstant    "stdin\|stdout\|stderr"

syn keyword rowlTodo        contained Todo TODO Fixme FIXME XXX

syn match   rowlSpecial     display contained "\\."
syn match   rowlCharacter   "'[^\\]'"
syn match   rowlCharacter   "'[^']*'" contains=rowlSpecial

syn region  rowlString      start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=rowlSpecial

syn match   rowlOperator    "=>\|!\|\\\|\`\|@\|:"

syn match   rowlHeader      "\<[A-Z][a-zA-Z0\9_]*"

syn match   rowlCurlyError  "}"
syn region  rowlBlock       start="{" end="}" contains=ALLBUT,rowlParen,rowlCurlyError fold

syn match   rowlNumber      display "\d\+\>"
syn match   rowlNumber      display "0x\x\+\>"
syn match   rowlOctal       display "0\o\+\>" contains=rowlOctalZero
syn match   rowlOctalZero   display "\<0"
syn match   rowlFloat       display "\d\+\.\d*\(e[-+]\=\d\+\)"

syn region  rowlComment start=/#/ end=/$/ contains=rowlTodo

hi def link rowlHeader              Type
hi def link rowlStandardConstant    Identifier
hi def link rowlOperator            Operator
hi def link rowlConstant            Constant
hi def link rowlStatement           Statement
hi def link rowlConditional         Conditional
hi def link rowlRepeat              Repeat
hi def link rowlTodo                Todo
hi def link rowlNumber              Number
hi def link rowlOctal               Number
hi def link rowlOctalZero           Number
hi def link rowlFloat               Float
hi def link rowlSpecialError        Error
hi def link rowlSpecial             SpecialChar
hi def link rowlCharacter           Character
hi def link rowlString              String
hi def link rowlCurlyError          Error
hi def link rowlComment             Comment

let b:current_syntax = "rowl"

" vim: ts=8
