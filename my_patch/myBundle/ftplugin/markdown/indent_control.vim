
" copy from vimoutliner
function! MyHoistableFoldLevel(line)
	let l:myindent = Ind(a:line)
	let l:nextindent = Ind(a:line+1)

	if HoistFold(a:line)
	  " if (a:line == 1)
		"	return g:hlevel
		" elseif (HoistFold(a:line-1) == 0)
		"	return ">".0
		" else
		"	return g:hlevel
		" endif
		return g:hlevel

	elseif BodyText(a:line)
		if (BodyText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (BodyText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedBodyText(a:line)
		if (PreformattedBodyText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedBodyText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedTable(a:line)
		if (PreformattedTable(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedTable(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedUserText(a:line)
		if (PreformattedUserText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedUserTextSpace(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedUserTextLabeled(a:line)
		if (PreformattedUserTextLabeled(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedUserText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif UserText(a:line)
		if (UserText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (UserTextSpace(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif UserTextLabeled(a:line)
		if (UserTextLabeled(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (UserText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	else
		if l:myindent < l:nextindent
			return '>'.(l:myindent+1)
		endif
		if l:myindent > l:nextindent
			return (l:myindent)
		endif
		return l:myindent
	endif
endfunction
" set foldmethod=expr
" set foldexpr=MyHoistableFoldLevel(v:lnum)
