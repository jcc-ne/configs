
" ClockStart(space) {{{1
" Insert a space, then the datetime.
function! ClockDay(space)
    let @x = ""
    if a:space == 1
        let @x = " "
    endif
	let @x = @x . strftime("%Y-%m-%d [09:00:00 -- 17:00:00] -> 8.00 h")
	normal! "xp
endfunction
imap <leader><leader>cd ~<Esc>x:call ClockDay(0)<CR>a
"}}}1
