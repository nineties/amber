" Language:	Amber
" Maintainer:	nineties <nineties48@gmail.com>
" $Id: amber.vim 2013-02-06 12:18:32 nineties $

if exists("b:current_syntax")
"    finish
endif

syn case match " case sensitive

syn keyword amberConstant    true false
syn keyword amberStatement   module return import open
syn keyword amberConditional if else where and or not
syn keyword amberRepeat      while

syn match   amberStandardConstant    "stdin\|stdout\|stderr"

syn keyword amberTodo        contained Todo TODO Fixme FIXME XXX

syn match   amberSpecial     display contained "\\."
syn match   amberCharacter   "'[^\\]'"
syn match   amberCharacter   "'[^']*'" contains=amberSpecial

syn region  amberString      start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=amberSpecial

syn match   amberOperator    "=>\|<=>\|!\|\\\|\`\|@\|:\|\<make\>"

syn match   amberHeader      "\<[A-Z][a-zA-Z0\9_]*"

syn match   amberCurlyError  "}"
syn region  amberBlock       start="{" end="}" contains=ALLBUT,amberParen,amberCurlyError fold

syn match   amberNumber      display "\<\d\+\>"
syn match   amberHex         display "\<0x\x\+\>"
syn match   amberOctal       display "\<0\o\+\>" contains=amberOctalZero
syn match   amberOctalZero   display "\<0\>"
syn match   amberFloat       display "\d\+\.\d*\(e[-+]\=\d\+\)"

syn region  amberComment start=/#/ end=/$/ contains=amberTodo

hi def link amberHeader              Type
hi def link amberStandardConstant    Identifier
hi def link amberOperator            Operator
hi def link amberConstant            Constant
hi def link amberStatement           Statement
hi def link amberConditional         Conditional
hi def link amberRepeat              Repeat
hi def link amberTodo                Todo
hi def link amberNumber              Number
hi def link amberHex                 Number
hi def link amberOctal               Number
hi def link amberOctalZero           Number
hi def link amberFloat               Float
hi def link amberSpecialError        Error
hi def link amberSpecial             SpecialChar
hi def link amberCharacter           Character
hi def link amberString              String
hi def link amberCurlyError          Error
hi def link amberComment             Comment

let b:current_syntax = "amber"

" vim: ts=8
