"#########################################################################
"# ftplugin/votl.vim: VimOutliner functions, commands and settings
"# version 0.4.0
"#   Copyright (C) 2001,2003 by Steve Litt (slitt@troubleshooters.com)
"#   Copyright (C) 2004,2014 by Noel Henson (noelwhenson@gmail.com)
"#
"#   This program is free software; you can redistribute it and/or modify
"#   it under the terms of the GNU General Public License as published by
"#   the Free Software Foundation; either version 2 of the License, or
"#   (at your option) any later version.
"#
"#   This program is distributed in the hope that it will be useful,
"#   but WITHOUT ANY WARRANTY; without even the implied warranty of
"#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"#   GNU General Public License for more details.
"#
"#   You should have received a copy of the GNU General Public License
"#   along with this program; if not, see <http://www.gnu.org/licenses/>.
"#
"# Steve Litt, slitt@troubleshooters.com, http://www.troubleshooters.com
"#########################################################################

" Load the plugin {{{1
" Prevent the plugin from being loaded twice
"if exists("b:did_ftplugin")
"  finish
"endif
"let b:did_ftplugin = 1
let b:current_syntax = "outliner"

" Default Preferences {{{1

" End User Preferences

" VimOutliner Standard Settings {{{1
setlocal autoindent
"setlocal backspace=2
setlocal wrapmargin=5
setlocal wrap
setlocal tw=78
setlocal noexpandtab
setlocal tabstop=4			" tabstop and shiftwidth must match
setlocal shiftwidth=4			" values from 2 to 8 work well
"setlocal nosmarttab
"setlocal softtabstop=0
setlocal foldlevel=20
setlocal foldcolumn=1			" turns on "+" at the beginning of close folds
setlocal foldmethod=expr
setlocal foldexpr=MyFoldLevel(v:lnum)
setlocal indentexpr=
setlocal nocindent
setlocal iskeyword=@,39,45,48-57,_,129-255

" Vim Outliner Functions {{{1

if !exists("loaded_vimoutliner_functions")
let loaded_vimoutliner_functions=1

" MyFoldText() {{{2
" Create string used for folded text blocks
function! MyFoldText()
    if exists('g:vo_fold_length') && g:vo_fold_length == "max"
        let l:foldlength = winwidth(0) - 1 - &numberwidth - &foldcolumn
    elseif exists('g:vo_fold_length')
        let l:foldlength = g:vo_fold_length
    else
        let l:foldlength = 58
    endif
    " I have this as an option, if the user wants to set "…" as the padding
    " string, or some other string, like "(more)"
    if exists('g:vo_trim_string')
        let l:trimstr = g:vo_trim_string
    else
        let l:trimstr = "..."
    endif
	let l:MySpaces = MakeSpaces(&sw)
	let l:line = getline(v:foldstart)
	let l:bodyTextFlag=0
	if l:line =~ "^\t* \\S" || l:line =~ "^\t*\:"
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[TEXT]"
	elseif l:line =~ "^\t*\;"
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[TEXT BLOCK]"
	elseif l:line =~ "^\t*\> "
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER]"
	elseif l:line =~ "^\t*\>"
		let l:ls = stridx(l:line,">")
		let l:le = stridx(l:line," ")
		if l:le == -1
			let l:l = strpart(l:line, l:ls+1)
		else
			let l:l = strpart(l:line, l:ls+1, l:le-l:ls-1)
		endif
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER ".l:l."]"
	elseif l:line =~ "^\t*\< "
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER BLOCK]"
	elseif l:line =~ "^\t*\<"
		let l:ls = stridx(l:line,"<")
		let l:le = stridx(l:line," ")
		if l:le == -1
			let l:l = strpart(l:line, l:ls+1)
		else
			let l:l = strpart(l:line, l:ls+1, l:le-l:ls-1)
		endif
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER BLOCK ".l:l."]"
	elseif l:line =~ "^\t*\|"
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[TABLE]"
	endif
	let l:sub = substitute(l:line,'\t',l:MySpaces,'g')
    let l:sublen = strdisplaywidth(l:sub)
	let l:end = " (" . ((v:foldend + l:bodyTextFlag)- v:foldstart)
	if ((v:foldend + l:bodyTextFlag)- v:foldstart) == 1
		let l:end = l:end . " line)"
	else
		let l:end = l:end . " lines)"
	endif
    let l:endlen = strdisplaywidth(l:end)

    " Multiple cases:
    " (1) Full padding with ellipse (...) or user defined string,
    " (2) No point in padding, pad would just obscure the end of text,
    " (3) Don't pad and use dashes to fill up the space.
    if l:endlen + l:sublen > l:foldlength
        let l:sub = strpart(l:sub, 0, l:foldlength - l:endlen - strdisplaywidth(l:trimstr))
        let l:sub = l:sub . l:trimstr
        let l:sublen = strdisplaywidth(l:sub)
        let l:sub = l:sub . l:end
    elseif l:endlen + l:sublen == l:foldlength
        let l:sub = l:sub . l:end
    else
        let l:sub = l:sub . " " . MakeDashes(l:foldlength - l:endlen - l:sublen - 1) . l:end
    endif
	return l:sub.repeat(' ', winwidth(0)-strdisplaywidth(l:sub))
endfunction
"}}}2
" Ind(line) {{{2
" Determine the indent level of a line.
" Courtesy of Gabriel Horner
function! Ind(line)
	return indent(a:line)/&tabstop
endfunction
"}}}2
" MyFoldLevel(Line) {{{2
" Determine the fold level of a line.
function MyFoldLevel(line)
	let l:myindent = Ind(a:line)
	let l:nextindent = Ind(a:line+1)

	if BodyText(a:line)
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
			"return '<'.(l:nextindent+1)
			return (l:myindent)
			"return '<'.(l:nextindent-1)
		endif
		return l:myindent
	endif
endfunction
"}}}2
" This should be a setlocal but that doesn't work when switching to a new .otl file
" within the same buffer. Using :e has demonstrated this.
set foldtext=MyFoldText()

"setlocal fillchars=|,

endif " if !exists("loaded_vimoutliner_functions")
" End Vim Outliner Functions

" Menu Entries {{{1
" VO menu
amenu &VO.Expand\ Level\ &1 :set foldlevel=0<cr>
amenu &VO.Expand\ Level\ &2 :set foldlevel=1<cr>
amenu &VO.Expand\ Level\ &3 :set foldlevel=2<cr>
amenu &VO.Expand\ Level\ &4 :set foldlevel=3<cr>
amenu &VO.Expand\ Level\ &5 :set foldlevel=4<cr>
amenu &VO.Expand\ Level\ &6 :set foldlevel=5<cr>
amenu &VO.Expand\ Level\ &7 :set foldlevel=6<cr>
amenu &VO.Expand\ Level\ &8 :set foldlevel=7<cr>
amenu &VO.Expand\ Level\ &9 :set foldlevel=8<cr>
amenu &VO.Expand\ Level\ &All :set foldlevel=99999<cr>
amenu &VO.-Sep1- :
"Tools sub-menu
let s:path2scripts = expand('<sfile>:p:h:h').'/vimoutliner/scripts'
" otl2html
exec 'amenu &VO.&Tools.otl2&html\.py\	(otl2html\.py\ thisfile\ -S\ html2otl_nnnnnn\.css\ >\ thisfile\.html) :!'.s:path2scripts.'/otl2html.py -S html2otl_nnnnnn.css % > %.html<CR>'
" otl2docbook
exec 'amenu &VO.&Tools.otl2&docbook\.pl\	(otl2docbook\.pl\ thisfile\ >\ thisfile\.dbk) :!'.s:path2scripts.'/otl2docbook.pl % > %.dbk<CR>'
" otl2table
exec 'amenu &VO.&Tools.otl2&table\.py\	(otl2table\.py\ thisfile\ >\ thisfile\.txt) :!'.s:path2scripts.'/otl2table.py % > %.txt<CR>'
" otl2tags => FreeMind
exec 'amenu &VO.&Tools.otl2tags\.py\ =>\ &FreeMind\	(otl2tags\.py\ \-c\ otl2tags_freemind\.conf\ thisfile\ >\ thisfile\.mm) :!'.s:path2scripts.'/otl2tags.py -c '.s:path2scripts.'/otl2tags_freemind.conf % > %.mm<CR>'
" otl2tags => Graphviz
exec 'amenu &VO.&Tools.otl2tags\.py\ =>\ &Graphviz\	(otl2tags\.py\ \-c\ otl2tags_graphviz\.conf\ thisfile\ >\ thisfile\.gv) :!'.s:path2scripts.'/otl2tags.py -c '.s:path2scripts.'/otl2tags_graphviz.conf % > %.gv<CR>'
amenu &VO.&Tools.&myotl2thml\.sh\	(myotl2html\.sh\ thisfile) :!myotl2html.sh %<CR>
amenu &VO.-Sep2- :
amenu &VO.&Color\ Scheme :popup Edit.Color\ Scheme<cr>
amenu &VO.-Sep3- :
amenu &VO.&Help.&Index :he vo<cr>
amenu &VO.&Help.&,,\ Commands :he votl-command<cr>
amenu &VO.&Help.&Checkboxes :he votl-checkbox<cr>
amenu &VO.&Help.&Hoisting :he votl-hoisting<cr>
amenu &Help.-Sep1- :
" Help menu additions
amenu &Help.&Vim\ Outliner.&Index :he votl<cr>
amenu &Help.&Vim\ Outliner.&,,\ Commands :he votl-command<cr>
amenu &Help.&Vim\ Outliner.&Checkboxes :he votl-checkbox<cr>
amenu &Help.&Vim\ Outliner.&Hoisting :he votl-hoisting<cr>
"}}}1
" Auto-commands {{{1
if !exists("autocommand_vo_loaded")
	let autocommand_vo_loaded = 1
	au BufNewFile,BufRead *.otl                     setf votl
"	au CursorHold *.otl                             syn sync fromstart
	"set updatetime=500
endif
"}}}1

" this command needs to be run every time so Vim doesn't forget where to look
setlocal tags^=$HOME/.vim/vimoutliner/vo_tags.tag

" Added an indication of current syntax as per Dillon Jones' request
let b:current_syntax = "outliner"

" Directory where VO is located now
let vo_dir = expand("<sfile>:p:h:h")

" Load rc file, only the first found.
let rcs = split(globpath('$HOME,$HOME/.vimoutliner','.vimoutlinerrc'), "\n") +
    \ split(globpath('$HOME,$HOME/.vimoutliner,$HOME/.vim', 'vimoutlinerrc'), "\n") +
    \ split(globpath(vo_dir, 'vimoutlinerrc'), "\n")

if len(rcs) > 0
	exec 'source '.rcs[0]
else
	runtime vimoutliner/vimoutlinerrc
endif
" Load modules
if exists('g:vo_modules_load')
	for vo_module in split(g:vo_modules_load, '\s*:\s*')
		exec "runtime! vimoutliner/plugin/votl_" . vo_module . ".vim"
	endfor
unlet! vo_module
endif

" Steve's additional mappings start here
" map <silent><buffer>   <C-L>         <C-]>
" map <silent><buffer>   <C-H>         <C-T>
"
map <silent><buffer>   <localleader>0           :set foldlevel=99999<CR>
map <silent><buffer>   <localleader>9           :set foldlevel=8<CR>
map <silent><buffer>   <localleader>8           :set foldlevel=7<CR>
map <silent><buffer>   <localleader>7           :set foldlevel=6<CR>
map <silent><buffer>   <localleader>6           :set foldlevel=5<CR>
map <silent><buffer>   <localleader>5           :set foldlevel=4<CR>
map <silent><buffer>   <localleader>4           :set foldlevel=3<CR>
map <silent><buffer>   <localleader>3           :set foldlevel=2<CR>
map <silent><buffer>   <localleader>2           :set foldlevel=1<CR>
map <silent><buffer>   <localleader>1           :set foldlevel=0<CR>
"next line commented out due to hard-coded nature and ancient, nonexistent file
"map <silent><buffer>   <localleader>,,          :runtime vimoutliner/vimoutlinerrc<CR>
" Steve's additional mappings end here

" End of Vim Outliner Key Mappings }}}1

" The End
" vim600: set foldmethod=marker foldlevel=0:
