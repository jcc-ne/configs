" -- line toggle --
if v:version >= 400
  function! RelativeNumberToggle()
    if (&number == 1 && &relativenumber == 1)
      set number
      set norelativenumber
    elseif (&number == 0 && &relativenumber == 1)
      set norelativenumber
      set number number?
    elseif (&number == 1 && &relativenumber == 0)
      set norelativenumber
      set nonumber number?
    else
      set number
      set relativenumber relativenumber?
    endif
  endfunc
else
  function! RelativeNumberToggle()
    if (&relativenumber == 1)
      set number number?
    elseif (&number == 1)
      set nonumber number?
    else
      set relativenumber relativenumber?
    endif
  endfunc
  nnoremap <silent><tabspace> :set number!<CR>
endif
nnoremap <leader>1 :call RelativeNumberToggle()<CR>

au FocusLost * :set number
au FocusGained * :set relativenumber
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber
