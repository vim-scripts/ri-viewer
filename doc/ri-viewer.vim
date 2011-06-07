" =============================================================================
" File:         ri-viewer.vim
" Last Changed: 2011-06-07
" Maintainer:   Daehyub Kim <lateau@gmail.com>
" Version:      1.0
" License:      Vim License
" =============================================================================

" based on perlhelp.vim from Lorance Stinson

" Changelog {{{1
" 1.0 2011-06-07
" Version 1.0

" Todo {{{1
"
" * Support old ri: doc-dirs
" * Syntax highlighting

" Initialization {{{1
" prevent duplicated loading
if exists('loaded_rihelp')
  finish
endif

let loaded_rihelp = 1

" make sure ri is executable
if exists('ri_prog')
  let s:ri_prog = ri_prog
else
  let s:ri_prog = 'ri'
endif
if !executable(s:ri_prog)
  echo 'ri is not your path or not installed'
  finish
endif

" set bufwin height
if exists('ri_height')
  let s:vheight = ri_height
else
  let s:vheight = 19
endif

" Commands {{{2
command! -nargs=? Ri call <sid>RiViewer(<f-args>)
command! -nargs=? RiCore call <sid>RiCore(<f-args>)
command! -nargs=? RiGem call <sid>RiGem(<f-args>)
command! -nargs=? RiHome call <sid>RiHome(<f-args>)
command! RiList call s:RiList()
command! RiDirs call s:RiDirs()

" Keymappings {{{2
nmap <silent> <unique> <leader>ri :call <SID>RiViewer(expand("<cword>"))<cr>
nmap <silent> <unique> <leader>rc :call <SID>RiCore(expand("<cword>"))<cr>
nmap <silent> <unique> <leader>rg :call <SID>RiGem(expand("<cword>"))<cr>
nmap <silent> <unique> <leader>rh :call <SID>RiHome(expand("<cword>"))<cr>

" Functions {{{1
" TODO: this is not completely implemented
" version check then set ri options
func! s:RiOptions(target)
  let l:ri_version = system(s:ri_prog . ' ' . '--version')

  if l:ri_version =~ '1\.[0-9]\.[0-9]'
    " TODO: NYI
    " old ri
    if a:target == 'core'
      let l:options = '-f plain -T --system --site'
    elseif a:target == 'gem'
      let l:options = '-f plain -T --gems'
    elseif a:target == 'home'
      let l:options = '-f plain -T --home'
    elseif a:target == 'list'
      let l:options = '-f plain -T --list-names'
    elseif a:target == 'dirs'
      let l:options = '--help'
    else
      let l:options = '-f plain -T --system --site --gems --home'
    endif
  else
    " standard ri included in ruby 1.9.x
    if a:target == 'core'
      let l:options = '-f rdoc -T --system --site --no-gems --no-home'
    elseif a:target == 'gem'
      let l:options = '-f rdoc -T --no-system --no-site --gems --no-home'
    elseif a:target == 'home'
      let l:options = '-f rdoc -T --no-system --no-site --no-gems --home'
    elseif a:target == 'list'
      let l:options = ''
    elseif a:target == 'dirs'
      let l:options = '--list-doc-dirs'
    else
      let l:options = '-f rdoc -T'
    endif
  endif

  return l:options
endfunc

func! s:RiOutput(keyword, options)
  " ri output
  let l:output = system(s:ri_prog . ' ' . a:options . ' ' . a:keyword)
  return l:output
endfunc

" Split the window or use the existing split to display the text.
" Taken from asciitable.vim by Jeffrey Harkavy.
func! s:RiBufferWindow(text)
  let s:vwinnum=bufnr('__RiViewer')
  if getbufvar(s:vwinnum, 'RiViewer')=='RiViewer'
    let s:vwinnum=bufwinnr(s:vwinnum)
  else
    let s:vwinnum=-1
  endif

  if s:vwinnum >= 0
    " if already exist
    if s:vwinnum != bufwinnr('%')
      exe "normal \<c-w>" . s:vwinnum . 'w'
    endif
    setlocal modifiable
    silent %d _
  else
    execute s:vheight.'split __RiViewer'

    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nonumber
    setlocal nowrap
    setlocal norightleft
    setlocal foldcolumn=0
    setlocal nofoldenable
    setlocal modifiable
    let b:RiViewer='RiViewer'
  endif

  silent put! = a:text
  setlocal nomodifiable
  set ft=text
  1 " Skip to the top of the text.
endfunc

" prompt for keywords lookup
func! s:RiPrompt()
  let l:prompt = input('Enter the keyword: ')
  return l:prompt
endfunc

" launcher
func! <sid>RiViewer(...)
  if a:0 == 0
    let l:keyword = s:RiPrompt()
  else
    let l:keyword = a:1
  endif
  let l:options = s:RiOptions('')
  let l:output = s:RiOutput(l:keyword, l:options)

  " display buffer window
  call s:RiBufferWindow(l:output)
endfunc

" include documentation from ruby standard lib only
func! <sid>RiCore(...)
  if a:0 == 0
    let l:keyword = s:RiPrompt()
  else
    let l:keyword = a:1
  endif
  let l:options = s:RiOptions('core')
  let l:output = s:RiOutput(l:keyword, l:options)

  " display buffer window
  call s:RiBufferWindow(l:output)
endfunc

" include documentation from rubygems only
func! <sid>RiGem(...)
  if a:0 == 0
    let l:keyword = s:RiPrompt()
  else
    let l:keyword = a:1
  endif
  let l:options = s:RiOptions('gem')
  let l:output = s:RiOutput(l:keyword, l:options)

  " display buffer window
  call s:RiBufferWindow(l:output)
endfunc

" include documentation from ~/.ri only
func! <sid>RiHome(...)
  if a:0 == 0
    let l:keyword = s:RiPrompt()
  else
    let l:keyword = a:1
  endif
  let l:options = s:RiOptions('home')
  let l:output = s:RiOutput(l:keyword, l:options)

  " display buffer window
  call s:RiBufferWindow(l:output)
endfunc

" display list
func! s:RiList()
  let l:options = s:RiOptions('list')
  let l:output = s:RiOutput('', l:options)

  " display buffer window
  call s:RiBufferWindow(l:output)
endfunc

" display ri dirs that can be included
func! s:RiDirs()
  let l:options = s:RiOptions('dirs')
  let l:output = s:RiOutput('', l:options)

  " display buffer window
  call s:RiBufferWindow(l:output)
endfunc

" vim: set foldmethod=marker ft=vim :
