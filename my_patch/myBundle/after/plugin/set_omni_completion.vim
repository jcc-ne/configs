" " use omni completion provided by lsp
"

function! SetOmni()
    set omnifunc=v:lua.vim.lsp.omnifunc
endfunction

" autocmd Filetype python
"
call SetOmni()
nnoremap <leader>om :call SetOmni()<CR>
