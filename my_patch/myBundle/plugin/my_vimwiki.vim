 " --- vimwiki

augroup my_vimwiki
    au BufRead,BufNewFile *.md set filetype=markdown
    au BufRead,BufNewFile *.task.md set filetype=markdown
    au BufRead,BufNewFile *.wiki set filetype=vimwiki

    autocmd FileType wiki,vimwiki vnoremap o <esc>I*<space>[<space>]<space><esc>
    autocmd FileType wiki,vimwiki vmap x <esc><C-space>
    autocmd FileType wiki,vimwiki vnoremap D <esc>0wdf]

    :autocmd FileType vimwiki map <leader>dl :VimwikiDiaryGenerateLinks

   function! ToggleCalendar()
     execute ":Calendar"
     if exists("g:calendar_open")
       if g:calendar_open == 1
         execute "q"
         unlet g:calendar_open
       else
         g:calendar_open = 1
       end
     else
       let g:calendar_open = 1
     end
   endfunction
   :autocmd FileType vimwiki map <leader>c :call ToggleCalendar() <cr>

    " open-able files within vim (will open in new tab)
    "{{{ Use Vim to open links with the
    " 'vlocal:' or 'vfile:' schemes.  E.g.:
    "   1) [[vfile:///~/Code/PythonProject/abc123.py]], and
    "   2) [[vlocal:./|Wiki Home]]

 function! VimwikiLinkHandler(link)
    " Use Vim to open external files with the 'vfile:' scheme.  E.g.:
    "   1) [[vfile:~/Code/PythonProject/abc123.py]]
    "   2) [[vfile:./|Wiki Home]]
    let link = a:link
    if link =~# '^vfile:' || link =~# '^vlocal:'
      let link = link[1:]
    else
      return 0
    endif
    let link_infos = vimwiki#base#resolve_link(link)
    if link_infos.filename == ''
      echom 'Vimwiki Error: Unable to resolve link!'
      return 0
    else
      exe 'tabnew ' . fnameescape(link_infos.filename)
      return 1
    endif
  endfunction
  autocmd FileType vimwiki exec "inoremap <silent> <leader><tab> <C-R>=UltiSnips#ExpandSnippet()<cr>"
  autocmd FileType vimwiki exec "nnoremap <silent> <c-,> :call UltiSnips#ExpandSnippet()<cr>"
  autocmd FileType vimwiki  set backspace=indent,start

  autocmd FileType vimwiki,totl exec "nnoremap <leader>tn :TaskWikiMod<cr>+next<cr>"
  autocmd FileType vimwiki,totl exec "nnoremap <leader>tj :TaskWikiMod<cr>-next<cr>"
  "--vvv roadmap will show up after completion in filtered history
  autocmd FileType vimwiki,totl exec "nnoremap <leader>tr :TaskWikiMod<cr>+roadmap<cr>"

  " -- don't show tasks until oneday before due (followup concept)
  autocmd FileType vimwiki nnoremap ,tw :TaskWikiMod<CR>due:7d<CR>:TaskWikiMod<CR>wait:due-1d<CR>:TaskWikiMod<CR>tag:followup<CR>
  autocmd FileType vimwiki nnoremap ,ty :TaskWikiMod<CR>tag:today<CR>
  autocmd FileType vimwiki nnoremap ,to :TaskWikiMod<CR>wait:14d<CR>:TaskWikiMod<CR>tag:followup<CR>

  au BufEnter *.md setlocal foldmethod=indent
  au BufEnter *.md setlocal foldlevel=20
  au BufEnter *.md set shiftwidth=4

augroup End
