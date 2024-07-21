set background=light
filetype plugin indent on
syntax on
set termguicolors
set sessionoptions+=globals
let mapleader = "\<Space>"
syntax off " This is removed in update_vim_colors_theme, in case an error in provision

" Save file shortcuts
nmap <c-s> :update<esc>
inoremap <c-s> <esc>:update<cr>

" To display a map: for example `:verbose map <leader>l`

" disable mouse to be able to select + copy
  set mouse=

" buffers
  nnoremap <F10> :buffers<cr>:buffer<Space>
  nnoremap <silent> <F12> :bn<cr>
  nnoremap <silent> <S-F12> :bp<cr>

" numbers maps
  set number norelativenumber
  nnoremap <leader>hh :set relativenumber!<cr>

" search visually selected text
  vmap * :<c-u>call <SID>VSetSearch()<cr>/<cr>
  vmap # :<c-u>call <SID>VSetSearch()<cr>?<cr>
  func! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
  endf

nnoremap <leader>eE :tabnew ~/development/environment/project/.vim-custom.lua<cr>
nnoremap <leader>er :lua dofile(os.getenv("HOME") .. '/development/environment/project/.vim-custom.lua')<cr>

" useful maps for macros
  nnoremap <leader>ee :tabnew ~/development/environment/src/config-files/.vim-macros.lua<cr>
  nnoremap <leader>ez _v$hy:let @="<c-r>""<C-home><right><right><right><right><right>
  " if adding to a register, use doube quotes and replace with:
    " \<C-[> => \<esc>
    " \<C-M> => \<cr>
    " b  => \<esc>
    "  => \<esc>
    " kb => \<bs>
    " <fd>V => \<C-Right>

" replace in selection
  vnoremap <leader>zr :<bs><bs><bs><bs><bs>%s/\%V\C//g<left><left><left>
  vnoremap <leader>zR :<bs><bs><bs><bs><bs>%s/\%V\C<c-r>"//g<left><left>

" prevent saving backup files
  set nobackup
  set noswapfile

" support all hex colors
  set  t_Co=256

" list mapped keys sorted. The asterisk means that the map is non recursive
  nnoremap <leader>M :tabnew<cr>ggVG<del>:put=execute('map')<cr>

" run saved command over file and reopen
  nnoremap <leader>kA :let g:File_cmd=''<left>
  nnoremap <leader>ka :!<c-r>=g:File_cmd<cr> %<cr>:e<cr>

" remove trailing spaces
  nmap <leader>T :%s/\s\+$<cr><c-o>

" override Ex mode
  nnoremap gQ vipgq
  vnoremap gQ <c-c>vipgq

" reload all saved files without warnings
  set autoread
  autocmd FocusGained * checktime
  nnoremap <leader>ec :checktime<cr>

" open url under cursor
  nnoremap <silent> gx :execute 'silent! !xdg-open ' . shellescape(expand('<cWORD>'), 1)<cr>

" fold by section
  let g:markdown_folding = 1

set nowrap
set nojoinspaces

autocmd Filetype markdown setlocal wrap linebreak nolist
autocmd Filetype text setlocal wrap linebreak nolist

" improve indentation
  xnoremap <Tab> >gv
  xnoremap <S-Tab> <gv

vnoremap <silent> y y`]
nnoremap <silent> p p`]
vnoremap <silent> p pgvy`]

set autoindent
set expandtab
set nohlsearch
set number
set shiftwidth=2
set smartcase
set softtabstop=2
set switchbuf+=usetab,newtab
set tabstop=2
set wildmenu

nnoremap <leader>zk v%

" this will display foo-bar in autocomplete
  set iskeyword+=-
  nnoremap <leader>z- :set iskeyword+=-<cr>
  nnoremap <leader>z_ :set iskeyword-=-<cr>

" ignore case in searches
  set ic

" line without break line
  nnoremap <leader>VV _vg_
  nnoremap <leader>VY ml_vg_y`l
  nnoremap <leader>VC _vg_dV"_d

nnoremap <silent> <leader>kdF :call delete(expand('%')) \| bdelete!<cr>:echo "FILE DELETED"<cr>
let g:Kx_map = ':let g:CurrentFileType=&ft<cr>:tabnew<c-r>=system("mktemp")<cr>
    \<cr>:set syntax=<c-r>=g:CurrentFileType<cr><cr>:set ft=<c-r>=g:CurrentFileType<cr><cr>'
execute 'nnoremap <leader>kx :' . g:Kx_map
execute 'vmap <leader>kx y' . g:Kx_map . 'Vp:w<cr>zR'
nnoremap <c-w>v :vsplit<cr><c-w><right>
cnoremap <c-A> <Home>
cnoremap <c-E> <End>
cnoremap <c-K> <c-U>

" line wrap
  nnoremap <leader>ww :set wrap linebreak nolist<cr>
  nnoremap <leader>wW :set nowrap<cr>

" remove autoindentation when pasting
  set pastetoggle=<F2>

nnoremap <leader>kw :tabnew <c-R>=expand("%:p:h") . "/" <cr>
nnoremap <leader>kW :e <c-R>=expand("%:p:h") . "/" <cr>
nnoremap <leader>ke :Mkdir <c-R>=expand("%:p:h") . "/"<cr>
nnoremap <leader>kE :Move <c-R>=expand("%:p:h") . "/"<cr>

vnoremap <leader>ku y:%s/\C<c-r>"//gn<cr>

" sort indent block. requires nmap. requires 2 plugins.
  nmap <leader>kl vii:sort<cr>
  " same as above but for objects without comma in the last item
  nmap <leader>hj  movii<c-c>A,<c-c>_vii:sort<cr>vii<c-c>A<backspace><c-c>`o

nnoremap <leader>ku viwy:%s/\C<c-r>"//gn<cr>
nnoremap <leader>x :set binary<cr>:set noeol<cr>:w<cr>:set nobinary<cr>:set eol<cr>
au BufNewFile,BufRead *.ejs set filetype=html

" move up/down from the beginning/end of lines
  set ww+=<,>

" always open file in new tab
  nnoremap gf <c-w>gf

nnoremap dd <Plug>(coc-definition)
nnoremap ds <Plug>(coc-references)
nnoremap di <Plug>(coc-implementation)
nnoremap df <c-w>gf
nnoremap D <Plug>(coc-definition)

nnoremap <leader>kv :%s/\t/  /g<cr>
inoremap <c-e> <esc>A
inoremap <c-a> <esc>I

nnoremap <leader>zf :let @" = expand("%")<cr>

vnoremap ; :<c-u>
nnoremap <leader>zx 'mzz
nnoremap <leader>jrw :call setreg("f", "<c-r>=expand("%:t:r")<cr>")<cr>
nnoremap <leader>jrW :call setreg("g", "<c-r>=expand("%:p")<cr>")<cr>

" use always the same cursor
  set guicursor=

" wrap quickfix window
  augroup quickfix
    autocmd!
    autocmd FileType qf setlocal wrap
  augroup END

" tabs
  nnoremap <leader>zz :tab split<cr>

" move by visual lines (for wrapped lines)
  map <down> gj
  map <up> gk

" highlight last inserted text
  nnoremap gV `[v`]

" use % to cycle html tags. Needs some time to test
runtime macros/matchit.vim

" for editing current search
nnoremap gs /<c-r>/

set scrolloff=3

" Move lines up and down
nnoremap <c-j> :m .+1<cr>==
nnoremap <c-k> :m .-2<cr>==
inoremap <c-j> <esc>:m .+1<cr>==gi
inoremap <c-k> <esc>:m .-2<cr>==gi
vnoremap <c-j> :m '>+1<cr>gv=gv
vnoremap <c-k> :m '<-2<cr>gv=gv

" improve the 'preview window' behaviour
  autocmd CompleteDone * pclose " close when done
  set splitbelow " move to the bottom

function! GetTabLine()
  let tabs = BuildTabs()
  let line = ''
  for i in range(len(tabs))
    let line .= (i+1 == tabpagenr()) ? '%#TabLineSel#' : '%#TabLine#'
    let line .= '%' . (i + 1) . 'T'
    let line .= ' ' . tabs[i].numstr . tabs[i].uniq_name . ' '
  endfor
  let line .= '%#TabLineFill#%T'
  return line
endfunction

function! BuildTabs()
  let tabs = []
  for i in range(tabpagenr('$'))
    let tabnum = i + 1
    let buflist = tabpagebuflist(tabnum)
    let file_path = ''
    let tab_name = bufname(buflist[0])
    if tab_name =~ 'NERD_tree' && len(buflist) > 1
      let tab_name = bufname(buflist[1])
    end
    let is_custom_name = 0
    if tab_name == ''
      let tab_name = '[No Name]'
      let is_custom_name = 1
    elseif tab_name =~ 'fzf'
      let tab_name = 'FZF'
      let is_custom_name = 1
    else
      let file_path = fnamemodify(tab_name, ':p')
      let tab_name = fnamemodify(tab_name, ':p:t')
    end
    let tab = {
      \ 'name': tab_name,
      \ 'numstr': tabnum . '. ',
      \ 'uniq_name': tab_name,
      \ 'file_path': file_path,
      \ 'is_custom_name': is_custom_name
      \ }
    call add(tabs, tab)
  endfor
  call CalculateTabUniqueNames(tabs)
  return tabs
endfunction

function! CalculateTabUniqueNames(tabs)
  for tab in a:tabs
    if tab.is_custom_name | continue | endif
    let tab_common_path = ''
    for other_tab in a:tabs
      if tab.name != other_tab.name || tab.file_path == other_tab.file_path
        \ || other_tab.is_custom_name
        continue
      endif
      let common_path = GetCommonPath(tab.file_path, other_tab.file_path)
      if tab_common_path == '' || len(common_path) < len(tab_common_path)
        let tab_common_path = common_path
      endif
    endfor
    if tab_common_path == '' | continue | endif
    let common_path_has_immediate_child = 0
    for other_tab in a:tabs
      if tab.name == other_tab.name && !other_tab.is_custom_name
        \ && tab_common_path == fnamemodify(other_tab.file_path, ':h')
        let common_path_has_immediate_child = 1
        break
      endif
    endfor
    if common_path_has_immediate_child
      let tab_common_path = fnamemodify(common_path, ':h')
    endif
    let path = tab.file_path[len(tab_common_path)+1:-1]
    let path = fnamemodify(path, ':~:.:h')
    let dirs = split(path, '/', 1)
    if len(dirs) >= 5
      let path = dirs[0] . '/.../' . dirs[-1]
    endif
    let tab.uniq_name = path . '/' . tab.name
  endfor
endfunction

function! GetCommonPath(path1, path2)
  let dirs1 = split(a:path1, '/', 1)
  let dirs2 = split(a:path2, '/', 1)
  let i_different = 0
  for i in range(len(dirs1))
    if get(dirs1, i) != get(dirs2, i)
      let i_different = i
      break
    endif
  endfor
  return join(dirs1[0:i_different-1], '/')
endfunction

" These functions are for displaying path in tab when two+ files have the same name
set tabline=%!GetTabLine()
set showtabline=2

function! CloseTab()
  normal o
  if winnr("$") == 1 && tabpagenr("$") > 1 && tabpagenr() > 1 && tabpagenr() < tabpagenr("$")
    tabclose | tabprev
  else
    q
  endif
endfunction
map <c-d> :call CloseTab()<CR>

nnoremap <leader>jk :put =strftime(\"%Y-%m-%d %H:%M:%S\")<cr>

" Open an existing tab using FZF
" http://ericnode.info/post/fzf_jump_to_tab_in_vim/
function TabName(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let name = bufname(buflist[winnr - 1])
  return fnamemodify(name, ':h') . '/' . fnamemodify(name, ':t')
endfunction

function! s:JumpToTab(line)
  let pair = split(a:line, ' ')
  let cmd = pair[0].'gt'
  execute 'normal' cmd
endfunction

nnoremap <silent> e :call fzf#run({
\   'source':  reverse(map(range(1, tabpagenr('$')), 'v:val." "." ".TabName(v:val)')),
\   'sink':    function('<sid>JumpToTab'),
\   'down':    tabpagenr('$') + 2
\ })<CR>

" 寄存器1是保留刪除的，沒有 "small yank" 寄存器
" 可以中斷 :h "redo-register"。仍然錯過任何手動寄存器 0 更改
augroup YankShift | au!
  let s:regzero = [getreg(0), getregtype(0)]
  autocmd TextYankPost * call <SID>yankshift(v:event)
augroup end

function! s:yankshift(event)
  if a:event.operator ==# 'y' && (empty(a:event.regname) || a:event.regname == '"')
    for l:regno in range(8, 2, -1)
      call setreg(l:regno + 1, getreg(l:regno), getregtype(l:regno))
    endfor
    call setreg(2, s:regzero[0], s:regzero[1])
    let s:regzero = [a:event.regcontents, a:event.regtype]
  elseif a:event.regname == '0'
    let s:regzero = [a:event.regcontents, a:event.regtype]
  endif
endfunction

hi Comment guifg=lightcyan

autocmd BufNewFile,BufRead Podfile,*.podspec set filetype=ruby
