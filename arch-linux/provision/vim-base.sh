# vim-base START

echo 'Control-x: " fg\n"' >> ~/.inputrc

cat > ~/.vimrc <<"EOF"
filetype plugin indent on
syntax on
set background=dark
set sessionoptions+=globals
let mapleader = "\<Space>"

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
  set norelativenumber
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

" replace in selection
  vnoremap <leader>r :<bs><bs><bs><bs><bs>%s/\%V\C//g<left><left><left>
  vnoremap <leader>R :<bs><bs><bs><bs><bs>%s/\%V\C<c-r>"//g<left><left>

" replace with selection. To replace by current register, use <c-r>0 to paste it
  vmap <leader>g "ay:%s/\C\<<c-r>a\>//g<left><left>

" fill the search bar with current text and allow to edit it
  vnoremap <leader>G y/<c-r>"
  nnoremap <leader>G viwy/<c-r>"

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
  nnoremap <leader>r zR
  nnoremap <leader>; za
  onoremap <leader>; <C-C>za
  vnoremap <leader>; zf

" override Ex mode
  nnoremap gQ vipgq
  vnoremap gQ <c-c>vipgq

" reload all saved files without warnings
  set autoread
  autocmd FocusGained * checktime
  nnoremap <leader>e :checktime<cr>

set nowrap

autocmd Filetype markdown setlocal wrap

" improve indentation
  xnoremap <Tab> >gv
  xnoremap <S-Tab> <gv

" fix c-b mapping to use with tmux (one page up)
  nnoremap <c-d> <c-b>

nnoremap <silent> <leader>s :if exists("g:syntax_on") \| syntax off \| else \| syntax enable \| endif<cr>

set autoindent
set clipboard=unnamedplus
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

" cut line without break line (but delete it)
  nnoremap <leader>V _v$<left>dV"_d

nnoremap <leader>y :reg<cr>
nnoremap <silent> <leader>kdF :call delete(expand('%')) \| bdelete!<cr>:echo "FILE DELETED"<cr>
let g:Kx_map = ':let g:CurrentFileType=&ft<cr>:tabnew<c-r>=system("mktemp")<cr>
    \<cr>:set syntax=<c-r>=g:CurrentFileType<cr><cr>:set ft=<c-r>=g:CurrentFileType<cr><cr>'
execute 'nnoremap <leader>kx :' . g:Kx_map
execute 'vmap <leader>kx y' . g:Kx_map . 'Vp:w<cr>zR'
nnoremap <c-w>v :vsplit<cr><c-w><right>
nnoremap <leader>w :set wrap!<cr>
nnoremap <leader>a ggvG$
nnoremap <leader>i :set list!<cr>
cnoremap <c-A> <Home>
cnoremap <c-E> <End>
cnoremap <c-K> <c-U>

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
nnoremap <leader>ko :mksession! ~/mysession.vim<cr>:qa<cr>
au BufNewFile,BufRead *.ejs set filetype=html

" move up/down from the beginning/end of lines
  set ww+=<,>

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
nnoremap <leader>/ :call setreg("f", "<c-r>=expand("%:t:r")<cr>")<cr>
nnoremap <leader>? :call setreg("g", "<c-r>=expand("%:p")<cr>")<cr>
nnoremap ' :<C-u>marks<CR>:normal! `

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
  nnoremap <c-d> :tabclose<cr>
  nnoremap <leader>zz :tab split<cr>
  " Rename tabs to show tab number.
  if exists("+showtabline")
      function! MyTabLine()
          let s = ''
          let wn = ''
          let t = tabpagenr()
          let i = 1
          while i <= tabpagenr('$')
              let buflist = tabpagebuflist(i)
              let winnr = tabpagewinnr(i)
              let s .= '%' . i . 'T'
              let s .= (i == t ? '%1*' : '%2*')
              let s .= ' '
              let wn = tabpagewinnr(i,'$')

              let s .= '%#TabNum#'
              let s .= i
              " let s .= '%*'
              let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
              let bufnr = buflist[winnr - 1]
              let file = bufname(bufnr)
              let buftype = getbufvar(bufnr, 'buftype')
              if buftype == 'nofile'
                  if file =~ '\/.'
                      let file = substitute(file, '.*\/\ze.', '', '')
                  endif
              else
                  let file = fnamemodify(file, ':p:t')
              endif
              if file == ''
                  let file = '[No Name]'
              endif
              let s .= ' ' . file . ' '
              let i = i + 1
          endwhile
          let s .= '%T%#TabLineFill#%='
          let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
          return s
      endfunction
      set stal=2
      set tabline=%!MyTabLine()
      set showtabline=1
  endif

" move by visual lines (for wrapped lines)
  map <down> gj
  map <up> gk

" highlight last inserted text
  nnoremap gV `[v`]

" http://vim.wikia.com/wiki/Insert_multiple_lines
  function! OpenLines(nrlines, dir)
    let nrlines = a:nrlines < 1 ? 1 : a:nrlines
    let start = line('.') + a:dir
    call append(start, repeat([''], nrlines))
    if a:dir < 0
      call cursor(start + 1, 0)
    else
      call cursor(start + nrlines, 0)
    endif
  endfunction
  " before using v:count
  nnoremap <Leader>o :<C-u>call OpenLines(2, 0)<CR>Vc
  nnoremap <Leader>O :<C-u>call OpenLines(2, -1)<CR>Vc

" http://vim.wikia.com/wiki/File:Xterm-color-table.png
" http://vim.wikia.com/wiki/File:Xterm-color-table.png
function! SetColors()
  hi DiffAdd     ctermbg=22
  hi DiffChange  ctermbg=52
  hi DiffText    ctermbg=red
  hi NonText     ctermfg=black
  hi Error       ctermbg=lightred ctermfg=black
  hi Folded      ctermbg=236      ctermfg=236
  hi IncSearch   gui=NONE         ctermbg=black ctermfg=red
  hi MatchParen  ctermfg=red      ctermbg=NONE
  hi Search      cterm=NONE       ctermfg=black ctermbg=white
  hi SpellBad    ctermbg=lightred ctermfg=black
  hi TabLine     ctermfg=gray     ctermbg=black
  hi TabLineFill ctermfg=black    ctermbg=black
  " better completion menu colors
    hi Pmenu ctermfg=white ctermbg=17
    hi PmenuSel ctermfg=white ctermbg=29
  hi link TabNum Special
  hi Visual ctermfg=white ctermbg=17
  hi clear ALEErrorSign
  hi clear ALEWarningSign

  hi Comment    cterm=NONE ctermfg=cyan  ctermbg=black
  hi LineNr     cterm=NONE ctermfg=gray  ctermbg=black
  hi String     cterm=NONE ctermfg=green ctermbg=black
  hi StatusLine cterm=NONE ctermfg=white ctermbg=black
  hi Todo       cterm=NONE ctermfg=black ctermbg=white

  hi Identifier cterm=NONE ctermfg=white ctermbg=black
  hi Type       cterm=NONE ctermfg=white ctermbg=black
  hi Constant   cterm=NONE ctermfg=white ctermbg=black
  hi Special    cterm=NONE ctermfg=white ctermbg=black
  hi Statement  cterm=NONE ctermfg=white ctermbg=black
  hi PreProc    cterm=NONE ctermfg=white ctermbg=black
endfunction

call SetColors()

" Know syntax type under cursor
nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
EOF

cp ~/.vimrc ~/.base-vimrc

# vim-extras available

# vim-base END
