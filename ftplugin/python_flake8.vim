"
" Python filetype plugin for running flake8
" Language:     Python (ft=python)
" Maintainer:   Vincent Driessen <vincent@3rdcloud.com>
" Version:      Vim 7 (may work with lower Vim versions, but not tested)
" URL:          http://github.com/nvie/vim-flake8
"
" Only do this when not done yet for this buffer
if exists("b:loaded_flake8_ftplugin")
    finish
endif
let b:loaded_flake8_ftplugin=1

function! Flake8()
	if exists("g:flake8_cmd")
		let s:flake8_cmd=g:flake8_cmd
	else
		let s:flake8_cmd="flake8"
	endif

	if !executable(s:flake8_cmd)
		echoerr "File " . s:flake8_cmd . " not found. Please install it first."
		return
	endif

	set lazyredraw   " delay redrawing

	" write any changes before continuing
	if &readonly == 0
		update
	endif

	" read config
	if exists("g:flake8_ignore")
		let s:flake8_ignores=" --ignore=".g:flake8_ignore
	else
		let s:flake8_ignores=""
	endif

	if exists("g:flake8_max_line_length")
		let s:flake8_max_line_length=" --max-line-length=".g:flake8_max_line_length
	else
		let s:flake8_max_line_length=""
	endif

	if exists("g:flake8_loc_open_cmd")
		let s:flake8_loc_open_cmd = g:flake8_loc_open_cmd
	else
		let s:flake8_loc_open_cmd = "copen"
	endif

	if exists("g:flake8_loc_close_cmd")
		let s:flake8_loc_close_cmd = g:flake8_loc_close_cmd
	else
		let s:flake8_loc_close_cmd = "cclose"
	endif

	" perform the grep itself
	" let &grepformat="%f:%l:%c: %m\,%f:%l: %m"
	" let &grepprg=s:flake8_cmd.s:flake8_builtins_opt.s:flake8_ignores.s:flake8_max_line_length.s:flake8_max_complexity
	" silent! grep! %

	let l:filepath = expand('%')
	let s:flake8_cmd = s:flake8_cmd . s:flake8_ignores .
					    \ s:flake8_max_line_length . ' ' . l:filepath
	let l:flake8_msg = system(s:flake8_cmd)

	let l:flake8_msg = substitute(l:flake8_msg, ": ", ":", "g")
	let l:flake8_list = split(l:flake8_msg, '\n')
	let s:loc_list = []

	for loc_line in flake8_list
		let loc_item_list = split(loc_line, ":")
		let l:loc_item = {}
		let l:loc_item.type = 'W'
		let l:loc_item.filename = loc_item_list[0]
		let l:loc_item.lnum = loc_item_list[1]
		let l:loc_item.col = loc_item_list[2]
		let l:loc_item.text =  loc_item_list[3]
		call add(s:loc_list, l:loc_item)
	endfor

	if len(s:loc_list) > 0
		call setloclist(0, s:loc_list)
		execute s:flake8_loc_open_cmd
		" execute
	else
		" Show OK status
		hi PEP8Green term=reverse ctermfg=white ctermbg=green guifg=#fefefe guibg=#00cc00 gui=bold
		echohl PEP8Green
		echon " - PEP8 check OK - "
		echohl
		execute s:flake8_loc_close_cmd
	endif

	set nolazyredraw
	redraw!
endfunction

" Add mappings, unless the user didn't want this.
" The default mapping is registered under to <F7> by default, unless the user
" remapped it already (or a mapping exists already for <F7>)
command! Flake8 call Flake8()
" noremap <buffer> <F7> :call Flake8()<CR>
