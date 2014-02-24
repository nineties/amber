" Language:	Amber
" Maintainer:	nineties <nineties48@gmail.com>
" $Id: amber.vim 2014-02-24 11:21:32 nineties $

if exists("b:current_syntax")
    finish
endif

syn case match " case sensitive

syn keyword amberSpecialSymbol  true false nil undef self stdin stdout stderr infinity
syn keyword amberStatement      when if else case of while for in continue break return throw try catch import as hiding export with reset shift trait require extend
syn keyword amberConditional    not and or
syn keyword amberTodo Todo TODO Fixme FIXME XXX contained
syn match amberComment  /#.*$/ contains=amberTodo
syn region amberString          start=/"/ skip=/\\"/ end=/"/ oneline
syn match amberConstant         /\<[A-Z_]\{2}\>/
syn match amberIdentifier       /\<[a-zA-Z_]\w*[!?]\=/
syn match amberSymbol           /\\[a-zA-Z_]\w*[!?]\=/
syn match amberHead             /\<[A-Z]\w*[!?]\=\>/ contains=amberConstant
syn match amberNumber           /\<\d\+\>/
syn match amberHex              /\<0x\x\+\>/
syn match amberOctal            /\<0\o\+\>/ contains=amberOctalZero
syn match amberOctalZero        /\<0\>/
syn match amberFloat            /\d\+\.\d*\(e[-+]\=\d\+\)/
"syn match amberOperator         /[%&\-=^\\|`@*:+/!?<>]/
syn match amberBlockError       /}/
syn region amberBlock   start=/{/ end=/}/ contains=ALLBUT,amberBlockError fold
syn match amberParenError       /)/
syn region amberParen   start=/(/ end=/)/ contains=ALLBUT,amberParenError fold
syn match amberListError        /\]/
syn region amberList    start=/\[/ end=/\]/ contains=ALLBUT,amberListError fold

syn match amberSpaceError       display excludenl "\s\+$"
syn match amberSpaceError       display " \+\t"
syn match amberSpaceError       display "\t\+ "

hi link amberSpecialSymbol      Constant
hi link amberStatement          Statement
hi link amberConditional        Conditional
hi link amberTodo               Todo
hi link amberComment            Comment
hi link amberString             String
hi link amberConstant           Constant
hi link amberSymbol             Constant
hi link amberHead               Structure
"hi link amberOperator           Operator
hi link amberBlockError         Error
hi link amberParenError         Error
hi link amberlistError          Error
hi link amberNumber             Number
hi link amberHex                Number
hi link amberOctal              Number
hi link amberOctalZero          Number
hi link amberFloat              Float
hi link amberSpaceError         Error

let b:current_syntax = "amber"

" vim: ts=8
