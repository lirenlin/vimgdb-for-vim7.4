" Mappings example for use with gdb
" Maintainer:	<xdegaye at users dot sourceforge dot net>
" Last Change:	Mar 6 2006

if ! has("gdb")
    finish
endif

let s:gdb_k = 1
function! ToggleGDB()
    if getwinvar(0,'&statusline') != ""
        :set autochdir
        :cd %:p:h
        :only
        set statusline=
        :call <SID>Toggle()
    else
        set statusline+=%F%m%r%h%w\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]
        :set noautochdir
        :call <SID>Toggle()
    endif
endfunction

function! SToggleGDB()
    :MiniBufExplorer
    set statusline+=%F%m%r%h%w\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]
    :call <SID>Toggle()
endfunction
nmap <F7>  :call ToggleGDB()<cr>
nmap <S-F7>  :call <SID>Toggle()<cr>

" nmap <S-F7>  :call SToggleGDB()<cr>
" nmap <F7>  :call <SID>Toggle()<CR>

" Toggle between vim default and custom mappings
function! s:Toggle()
    if s:gdb_k
	let s:gdb_k = 0
    call <SID>SaveMap()
	map <Space> :call gdb("")<CR>
	nmap <silent> <C-Z> :call gdb("\032")<CR>

	nmap <silent> B :call gdb("info breakpoints")<CR>
	nmap <silent> L :call gdb("info locals")<CR>
	nmap <silent> A :call gdb("info args")<CR>
	nmap <silent> S :call gdb("step")<CR>
	nmap <silent> I :call gdb("stepi")<CR>
	nmap <silent> <C-N> :call gdb("next")<CR>
	nmap <silent> X :call gdb("nexti")<CR>
	nmap <silent> F :call gdb("finish")<CR>
	nmap <silent> R :call gdb("run")<CR>
	nmap <silent> Q :call gdb("quit")<CR>
	nmap <silent> C :call gdb("continue")<CR>
	nmap <silent> W :call gdb("where")<CR>
	nmap <silent> <C-U> :call gdb("up")<CR>
	nmap <silent> <C-D> :call gdb("down")<CR>

	" set/clear bp at current line
	nmap <silent> <C-B> :call <SID>Breakpoint("break")<CR>
	nmap <silent> <C-E> :call <SID>Breakpoint("clear")<CR>

	" print value at cursor
	nmap <silent> <C-P> :call gdb("print " . expand("<cword>"))<CR>

	" display Visual selected expression
	vmap <silent> <C-P> y:call gdb("createvar " . "<C-R>"")<CR>

	" print value referenced by word at cursor
	nmap <silent> <C-X> :call gdb("print *" . expand("<cword>"))<CR>

	echohl ErrorMsg
	echo "gdb keys mapped"
	echohl None

    " Restore vim defaults
    else
	let s:gdb_k = 1
	unmap <Space>
	nunmap <C-Z>

	nunmap B
	nunmap L
	nunmap A
	nunmap S
	nunmap I
	nunmap <C-N>
	nunmap X
	nunmap F
	nunmap R
	nunmap Q
	nunmap C
	nunmap W
	nunmap <C-U>
	nunmap <C-D>

	nunmap <C-B>
	nunmap <C-E>
	nunmap <C-P>
	vunmap <C-P>
	nunmap <C-X>

    call <SID>restoreMap()
    echohl ErrorMsg
	echo "gdb keys reset to default"
	echohl None
    endif
endfunction

" Run cmd on the current line in assembly or symbolic source code
" parameter cmd may be 'break' or 'clear'
function! s:Breakpoint(cmd)
    " An asm buffer (a 'nofile')
    if &buftype == "nofile"
	" line start with address 0xhhhh...
	let s = substitute(getline("."), "^\\s*\\(0x\\x\\+\\).*$", "*\\1", "")
	if s != "*"
	    call gdb(a:cmd . " " . s)
	endif
    " A source file
    else
	let s = "\"" . fnamemodify(expand("%"), ":p") . ":" . line(".") . "\""
	call gdb(a:cmd . " " . s)
    endif
endfunction

" map vimGdb keys
"call s:Toggle()

" save original key mapping string
let s:savedMap = []
function! s:SaveMap()
    if len(s:savedMap) != 0
        let s:savedMap = []
    endif
    let mapkeys = {"n":["<Space>", "<C-Z>", "B", "L", "A", "S", "I", "<C-N>",
                    \"X", "F", "R", "Q", "C", "W", "<C-U>", "<C-D>", "<C-B>",
                    \"<C-E>", "<C-P>", "<C-X>"],
                \"v":["<Space>", "<C-P>"],
                \"o":["<Space>"]}

    for mode in keys(mapkeys)
        for key in mapkeys[mode]
            let keyMap = maparg(key, mode)
            if keyMap != ""
                let cmd = mode."map ".key." ".keyMap
                call add(s:savedMap, cmd)
            endif
        endfor
    endfor
endfunction

" restore original key mapping
function! s:restoreMap()
    if len(s:savedMap) != 0
        for item in s:savedMap
            execute item
        endfor
    endif
endfunction


function! s:DisableMap()
    if &syntax != 'gdbvim'
        return
    endif

    if !s:gdb_k
        noremap <buffer> <Space> <Space>
        nnoremap <buffer> <C-Z> <C-Z>

        nnoremap <buffer> B B
        nnoremap <buffer> L L
        nnoremap <buffer> A A
        nnoremap <buffer> S S
        nnoremap <buffer> I I
        nnoremap <buffer> <C-N> <C-N>
        nnoremap <buffer> X X
        nnoremap <buffer> F F
        nnoremap <buffer> R R
        nnoremap <buffer> Q Q
        nnoremap <buffer> C C
        nnoremap <buffer> W W
        nnoremap <buffer> <C-U> <C-U>
        nnoremap <buffer> <C-D> <C-D>

        nnoremap <buffer> <C-B> <C-B>
        nnoremap <buffer> <C-E> <C-E>
        nnoremap <buffer> <C-P> <C-P>
        vnoremap <buffer> <C-P> <C-P>
        nnoremap <buffer> <C-X> <C-X>

        echohl ErrorMsg
        echo "gdb keys reset to default in gdb buffer"
        echohl None
    endif
endfunction

autocmd BufEnter * :call <SID>DisableMap()
