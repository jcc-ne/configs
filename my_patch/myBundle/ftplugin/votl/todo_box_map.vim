vmap o <localleader>c% " add checkbox
vmap x <localleader>cx " toggle checkbox
vmap D <localleader>cd " delete checkbox

function! LinkForward()
   let g:fromFile=expand('%:p')
   let fn= substitute(getline('.'),'^.*\[\[\([^\]]*\)\].*$',"\\1",'g')
   execute "w"
   execute "tabnew ".fn
endfunction

nnoremap <cr> :call LinkForward()<cr>
