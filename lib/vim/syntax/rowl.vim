" Language:	Rowl
" Maintainer:	nineties <nineties48@gmail.com>
" Last Change:	2010 Jan 17

if exists("b:current_syntax")
    finish
endif

syn case match

syn keyword rowlCommand   goto label return 
syn keyword rowlSymbol    if else syscall while
syn keyword rowlExternal  include export
syn keyword rowlType      char int
syn match rowlIdentifier /\<\h\w*/
syn match rowlInteger    /-\?\(0\o*\|[1-9]\d*\|0x\x\+\)\>/
syn match rowlEscape     /\\['"?\\abfnrtv0]/ contained
syn match rowlCharacter  /'\(\\["?\\abfnrtv0]\|[^\\\n]\)'/ contains=rowlEscape
syn match rowlString     /"\(\\['"?\\abfnrtv0]\|[^\\\"\n]\)*"/ contains=rowlEscape
syn keyword rowlTodo TODO FIXME NOTE XXX contained
syn region  rowlString start=/"/ skip=/\\"/ end=/"/
syn region  rowlComment start=/(%/ end=/%)/ contains=rowlComment,rowlTodo
syn region  rowlTuple start=/(/ end=/)/ contains=ALL
syn region  rowlList  start=/{/ end=/}/ contains=ALL
syn region  rowlArray start=/\[/ end=/\]/ contains=ALL

syn match rowlDecl "\(\<\h\w*\s*\):" contains=rowlDeclOp
syn match rowlDecl "\(\<\h\w*\s*\)=>" contains=rowlDeclOp
syn match rowlDeclOp ":"
syn match rowlDeclOp "=>"

hi def link rowlComment     Comment
hi def link rowlCharacter   Character
hi def link rowlEscape      SpecialChar
hi def link rowlDeclOp      SpecialChar
hi def link rowlString      String
hi def link rowlInteger     Number
hi def link rowlDecl        Keyword
hi def link rowlCommand     Statement
hi def link rowlSymbol      Statement
hi def link rowlExternal    PreProc
hi def link rowlType        Type
hi def link rowlTodo        Keyword

let b:current_syntax = "rowl"

" vim: ts=8
