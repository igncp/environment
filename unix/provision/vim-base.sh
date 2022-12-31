# vim-base START

cat > ~/.vimrc <<"EOF"
set background=light
filetype plugin indent on
syntax on
set sessionoptions+=globals
let mapleader = "\<Space>"
syntax off " This is removed in update_vim_colors_theme, in case an error in provision

" disable mouse to be able to select + copy
  set mouse-=a

" buffers
  nnoremap <F10> :buffers<cr>:buffer<Space>
  nnoremap <silent> <F12> :bn<cr>
  nnoremap <silent> <S-F12> :bp<cr>

" don't copy when using del
  vnoremap <Del> "_d
  nnoremap <Del> "_d

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

" useful maps for macros
  nnoremap Q @q
  nnoremap <leader>eE :tabnew ~/project/provision/vim-macros-custom<cr>
  nnoremap <leader>ee :tabnew ~/.vim-macros<cr>
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

" replace with selection. To replace by current register, use <c-r>0 to paste it
  vmap <leader>g "ay:%s/\C\<<c-r>a\>//g<left><left>
  vmap <leader>G "ay:%s/\C<c-r>a//g<left><left>

" fill the search bar with current text and allow to edit it
  vnoremap <leader>/ y/<c-r>"
  nnoremap <leader>/ viwy/<c-r>"

" prevent saving backup files
  set nobackup
  set noswapfile

" support all hex colors
  set  t_Co=256

" list mapped keys sorted. The asterisk means that the map is non recursive
  nnoremap <leader>M :redir! > /tmp/vim_keys.txt<cr>:silent verbose map<cr>:redir END<cr>
    \:-tabnew\|te cat /tmp/vim_keys.txt \| grep -v "Last set" \| grep -v "<Plug>"
    \ \| sort -k 1.4 \| less<cr>

" run saved command over file and reopen
  nnoremap <leader>kA :let g:File_cmd=''<left>
  nnoremap <leader>ka :!<c-r>=g:File_cmd<cr> %<cr>:e<cr>

" move lines up and down
  nnoremap <c-j> :m .+1<cr>==
  nnoremap <c-k> :m .-2<cr>==
  inoremap <c-j> <esc>:m .+1<cr>==gi
  inoremap <c-k> <esc>:m .-2<cr>==gi
  vnoremap <c-j> :m '>+1<cr>gv=gv
  vnoremap <c-k> :m '<-2<cr>gv=gv

" remove trailing spaces
  nmap <leader>t :%s/\s\+$<cr><c-o>

" folding
  set foldlevelstart=20
  set foldmethod=indent
  set fml=0
  nnoremap <leader>fr :set foldmethod=manual<cr>
  nnoremap <leader>fR :set foldmethod=indent<cr>
  vnoremap <leader>ft <c-c>:set foldmethod=manual<cr>mlmk`<kmk`>jmlggvG$zd<c-c>'kVggzf'lVGzfgg<down>
  nnoremap <leader>; za
  onoremap <leader>; <C-C>za
  vnoremap <leader>; zf

" override Ex mode
  nnoremap gQ vipgq
  vnoremap gQ <c-c>vipgq

" reload all saved files without warnings
  set autoread
  autocmd FocusGained * checktime
  nnoremap <leader>ec :checktime<cr>

" open url under cursor
  nnoremap <silent> gx :execute 'silent! !xdg-open ' . shellescape(expand('<cWORD>'), 1)<cr>

" copy to clipboard
  vnoremap <leader>i "+y
  nnoremap <leader>i viw"+y
  nnoremap <leader>I viW"+y

" fold by section
  let g:markdown_folding = 1

set nowrap
set nojoinspaces

autocmd Filetype markdown setlocal wrap linebreak nolist
autocmd Filetype text setlocal wrap linebreak nolist

" improve indentation
  xnoremap <Tab> >gv
  xnoremap <S-Tab> <gv

nnoremap <silent> <leader>s :if exists("g:syntax_on") \| syntax off \| else \| syntax enable \| endif<cr>

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
nnoremap <leader>a ggVG$
nnoremap <leader>u :set list!<cr>
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

nnoremap <leader>c" _f"ci"

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

nnoremap <leader>kv :%s/\t/  /g<cr>
vnoremap <F4> :sort<cr>
inoremap <c-e> <esc>A
inoremap <c-a> <esc>I
vnoremap <silent> y y`]
nnoremap <silent> p p`]
vnoremap <silent> p pgvy`]
nnoremap <leader>zk v%
nnoremap <leader>zK v%<del>
nnoremap <leader>zf :let @" = expand("%")<cr>
vnoremap ; :<c-u>
nnoremap <leader>zx 'mzz
nnoremap <leader>jrw :call setreg("f", "<c-r>=expand("%:t:r")<cr>")<cr>
nnoremap <leader>jrW :call setreg("g", "<c-r>=expand("%:p")<cr>")<cr>
" nnoremap ' :<C-u>marks<CR>:normal! `

" use always the same cursor
  set guicursor=

" delete from cursor to end of line
  inoremap <C-Del> <C-\><C-O>D

" save file shortcuts
  nmap <c-s> :update<esc>
  inoremap <c-s> <esc>:update<cr>

" quickly move to lines
  nnoremap <cr> G
  nnoremap <bs> gg

" wrap quickfix window
  augroup quickfix
    autocmd!
    autocmd FileType qf setlocal wrap
  augroup END

" tabs
  nnoremap r gt
  nnoremap R gT
  nnoremap <leader>1 1gt
  nnoremap <leader>2 2gt
  nnoremap <leader>3 3gt
  nnoremap <leader>4 4gt
  nnoremap <leader>5 5gt
  nnoremap <leader>6 6gt
  nnoremap <leader>7 7gt
  nnoremap <leader>8 8gt
  nnoremap <leader>9 9gt
  nnoremap <c-g> :execute "tabmove" tabpagenr() - 2 <cr>
  nnoremap <c-l> :execute "tabmove" tabpagenr() + 1 <cr>
  " add ':e' to paste a PATH_TO_FILE:LINE_NUMBER from fast grep
  nnoremap <c-t> :tabnew<cr>:e <left><right>
  nnoremap <leader>zz :tab split<cr>

" move by visual lines (for wrapped lines)
  map <down> gj
  map <up> gk

" highlight last inserted text
  nnoremap gV `[v`]

" replace quotes
nnoremap <leader>` f`a<BS>'<c-c>f`a<BS>'<c-c>l

so ~/.vim/colors.vim

" Know syntax type under cursor
nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" use % to cycle html tags. Needs some time to test
runtime macros/matchit.vim

" for editing current search
nnoremap gs /<c-r>/

set scrolloff=3

" copy - paste between files and VMs
  vmap <leader>ff "+y
  vmap <leader>fy "uy:-tabnew /tmp/vim-shared<cr>ggVG"up:x<cr>
  nmap <leader>fp :-tabnew /tmp/vim-shared<cr>gg_vG$<left>"uy:q!<cr>"up
  vmap <leader>fp <c-c>:-tabnew /tmp/vim-shared<cr>ggvG$<left>"uy:q!<cr>gv"up

" improve the 'preview window' behaviour
  autocmd CompleteDone * pclose " close when done
  set splitbelow " move to the bottom
EOF
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|set background=.*|set background=dark|' ~/.vimrc
fi

cat >> ~/.vimrc <<"EOF"
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

if !exists('g:lasttab')
  let g:lasttab = 1
endif
nmap <leader>zt :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
EOF

cat >> ~/.vimrc <<"EOF"
function! ClearRegs()
  let regs='abcdefghijklmnopqrstuvwxyz"'
  let i=0
  while (i<strlen(regs))
    exec 'let @'.regs[i].'=""'
    let i=i+1
  endwhile
  unlet regs
endfunction!

function! ShowRegs()
  redir => l:registersOutput
      silent! execute 'registers abcdefghijklmnopqrstuvwxyz"'
  redir END
  call writefile([""], '/tmp/regs.txt')
  for l:line in split(l:registersOutput, "\n")
      if l:line !~# '^"\S\s*$'
          " echo l:line
          call writefile(split(l:line, "\n", 1), '/tmp/regs.txt', 'a')
      endif
  endfor
  execute ':-tabnew|te cat /tmp/regs.txt | sed "s|^|  |" | less -S'
endfunction!

nnoremap "" :call ShowRegs()<CR>
nnoremap ". :call ClearRegs()<CR>
EOF

cat >> ~/.vimrc <<"EOF"
function! AddNewListItem(del, reg)
  let ch_in_line = getline('.') =~ a:reg

  if ch_in_line == 0
    execute "normal vi" . a:del
    execute "normal zz"
    execute "normal \<c-c>"

    let ch = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')

    if ch != ','
      execute "normal A,\<c-c>o"
    endif
  else
    exe "normal f" . a:del

    let ch1 = matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
    let ch2 = matchstr(getline('.'), '\%' . (col('.') - 2) . 'c.')

    if ch1 == ',' || ch2 == ','
      execute 'normal i '
    elseif ch1 == ' '
      execute 'normal hi, '
      execute 'normal l'
    else
      execute 'normal i, '
      execute 'normal l'
    endif
  endif

  startinsert
endfunction

nnoremap <silent> <leader>m} :call AddNewListItem("}", "\}")<cr>
nnoremap <silent> <leader>m) :call AddNewListItem(")", "\)")<cr>
nnoremap <silent> <leader>m] :call AddNewListItem("]", "\]")<cr>
EOF

cp ~/.vimrc ~/.base-vimrc

# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
update_vim_colors_theme() {
  sed -i '/syntax off/d' ~/.vimrc
  if [ "$ENVIRONMENT_THEME" == 'light' ]; then return; fi
  swap_colors() {
    COLOR1="$1"; COLOR2="$2"

    sed -i "s|=$COLOR1|=TMP_$COLOR2|" ~/.vim/colors.vim
    sed -i "s|=$COLOR2|=$COLOR1|" ~/.vim/colors.vim
    sed -i "s|=TMP_$COLOR2|=$COLOR2|" ~/.vim/colors.vim
  }

  swap_colors black white
  swap_colors darkgrey lightgrey
  swap_colors darkcyan lightcyan
  swap_colors darkgreen lightgreen
  swap_colors darkblue lightblue
  swap_colors darkred lightred
  swap_colors darkyellow lightyellow

  sed -i "s|darkcyan|18|" ~/.vim/colors.vim
}

mkdir -p ~/.vim
cat > ~/.vim/colors.vim <<"EOF"
" http://vim.wikia.com/wiki/File:Xterm-color-table.png
  hi DiffAdd     ctermbg=22
  hi DiffChange  ctermbg=52
  hi DiffText    ctermbg=red
  hi NonText     ctermfg=white
  hi Error       ctermbg=white      ctermfg=red
  hi ErrorMsg    ctermbg=white      ctermfg=darkred
  hi Folded      ctermfg=darkgrey   ctermbg=NONE
  hi IncSearch   cterm=NONE         ctermbg=lightcyan   ctermfg=black
  hi MatchParen  ctermfg=red        ctermbg=lightgrey
  hi Search      cterm=NONE         ctermfg=white       ctermbg=black
  hi SpellBad    ctermbg=lightred   ctermfg=white
  hi TabLine     ctermfg=gray       ctermbg=white
  hi TabLineFill ctermfg=white      ctermbg=white
  " better completion menu colors
    hi Pmenu ctermfg=black ctermbg=lightgrey
    hi PmenuSel ctermfg=black ctermbg=lightcyan
  hi link TabNum Special
  hi Visual ctermfg=black ctermbg=lightgrey

  hi shTodo ctermfg=white ctermbg=black
  hi rustTodo ctermfg=white ctermbg=black
  hi typescriptCommentTodo ctermfg=white ctermbg=black
  hi javaScriptCommentTodo ctermfg=white ctermbg=black

  hi Comment    cterm=NONE ctermfg=darkcyan  ctermbg=NONE
  hi LineNr     cterm=NONE ctermfg=gray  ctermbg=NONE
  hi String     cterm=NONE ctermfg=darkgreen ctermbg=NONE
  hi StatusLine cterm=NONE ctermfg=black ctermbg=NONE
  hi Todo       cterm=NONE ctermfg=white ctermbg=NONE

  hi SignColumn cterm=NONE ctermfg=black ctermbg=NONE
  hi Identifier cterm=NONE ctermfg=black ctermbg=NONE
  hi Type       cterm=NONE ctermfg=black ctermbg=NONE
  hi Constant   cterm=NONE ctermfg=black ctermbg=NONE
  hi Special    cterm=NONE ctermfg=black ctermbg=NONE
  hi Statement  cterm=NONE ctermfg=black ctermbg=NONE
  hi PreProc    cterm=NONE ctermfg=black ctermbg=NONE

  hi CursorLineNr ctermfg=grey
EOF

cat >> ~/.vimrc <<"EOF"
function XDisplayColor(color)
  let displaycommand = "display -size 300x300 xc:'" . a:color . "'"
  execute "!" . displaycommand . " 2>&1 >/dev/null &"
  :redraw!
endfunction

function ShowHexColorUnderCursor()
  let wordundercursor = expand("<cword>")
  let parsed_word = substitute(wordundercursor, "#", "", "")
  :call XDisplayColor('\#'.parsed_word)
endfunction

map <leader>cf :call ShowHexColorUnderCursor()<CR>
EOF

# Open an existing tab using FZF
cat >> ~/.vimrc <<"EOF"
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
EOF

if [ -f ~/project/.config/netcat-clipboard ]; then
  sed '/leader>i/d' -i ~/.vimrc
  cat >> ~/.vimrc <<"EOF"
vnoremap <leader>i y:call writefile(getreg('0', 1, 1), "/tmp/netcat-clipboard")<cr>:silent !sh ~/.scripts/netcat-clipboard.sh<cr>
EOF
fi

# vim-extra available

# vim-base END
