" Vim indent file
" Language:     Amber
" Maintainers:	nineties <nineties48@gmail.com>
" Last Change:	2012 Jan 19

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetAmberIndent()
setlocal indentkeys=0},0),0],!^F,o,O,e

if exists("*GetAmberIndent")
  finish
endif

function! SkipBlanksAndComments(startline)
  let lnum = a:startline
  while lnum > 1
    let lnum = prevnonblank(lnum)
    if getline(lnum) =~ '^\s*#'
      let lnum = lnum - 1
    else
      break
    endif
  endwhile
  return lnum
endfunction

function GetAmberIndent()
  let theIndent = cindent(v:lnum)

  return theIndent
endfunction

" vim:sw=2
