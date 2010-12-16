" Vim indent file
" Language:     Rowl
" Maintainers:	nineties <nineties48@gmail.com>
" Last Change:	2010 Jan 17

if exists("b:did_indent")
 finish
endif
let b:did_indent = 1

setlocal indentexpr=GetRowlIndent()
setlocal indentkeys=0},0),0],!^F,o,O,e

if (has("comments"))
 setlocal comments=sr:(%,mb:%,ex:%)
 setlocal fo=cqort
endif

if exists("*GetRowlIndent")
  finish
endif

function s:PrevNonComment(lnum)
  let in_comm = 0
  let lnum = prevnonblank(a:lnum)
  while lnum > 0
    let line = getline(lnum)
    if line =~ '(%'
      if in_comm
        let in_comm = 0
      else
        break
      endif
    elseif !in_comm && line =~ '%);'
      let in_comm = 1
    elseif !in_comm
      break
    endif
    let lnum = prevnonblank(lnum - 1)
  endwhile
  return lnum
endfunction

function GetRowlIndent()
  " find a non-blank line above the current line.
  let lnum = s:PrevNonComment(v:lnum - 1)
  
  if lnum == 0
    return 0
  endif

  let ind = indent(lnum)
  let prevline = getline(lnum)
  if prevline =~ '^\s*\(if\>\|else\>while\>\)' || prevline =~ '{\s*$'
        \ || prevline =~ '^\.\+[:=]'
    let ind = ind + &shiftwidth
  endif

  let line = getline(v:lnum)
  if line =~ '^\s*}'
    let ind = ind - &shiftwidth
  endif
  return ind
endfunction

" vim:sw=2
