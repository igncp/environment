# vim START

install_vim_package() {
  REPO=$1
  DIR=$(echo $REPO | sed -r "s|.+/(.+)|\1|") # foo/bar => bar
  EXTRA_CMD=$2
  if [ ! -d ~/.vim/bundle/"$DIR" ]; then
    echo "installing $REPO"
    git clone https://github.com/$REPO.git ~/.vim/bundle/"$DIR"
    if [[ ! -z $EXTRA_CMD ]]; then eval $EXTRA_CMD; fi
  fi
}

mkdir -p ~/.vim/autoload/ ~/.vim/bundle
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
  curl https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim \
    > ~/.vim/autoload/pathogen.vim
fi

install_pacman_package neovim nvim
install_pacman_package python3
install_pacman_package python-pip pip3

if [ ! -f ~/.check-files/neovim ] ; then
  sudo pip3 install neovim
  mkdir -p ~/.config
  rm -rf ~/.config/nvim
  ln -s ~/.vim ~/.config/nvim
  ln -s ~/.vimrc ~/.config/nvim/init.vim
  mkdir -p ~/.check-files && touch ~/.check-files/neovim
fi
git config --global core.editor nvim # faster than sed

install_vim_package airblade/vim-gitgutter
install_vim_package airblade/vim-rooter
install_vim_package andrewRadev/splitjoin.vim # gS, gJ
install_vim_package bogado/file-line
install_vim_package ctrlpvim/ctrlp.vim
install_vim_package easymotion/vim-easymotion
install_vim_package elzr/vim-json
install_vim_package evidens/vim-twig
install_vim_package flazz/vim-colorschemes
install_vim_package haya14busa/incsearch.vim
install_vim_package honza/vim-snippets "find ~/.vim/bundle/vim-snippets/snippets/ -type f | xargs sed -i 's|:\${VISUAL}||'"
install_vim_package jiangmiao/auto-pairs
install_vim_package junegunn/limelight.vim
install_vim_package kana/vim-textobj-indent
install_vim_package kana/vim-textobj-user
install_vim_package luochen1990/rainbow
install_vim_package majutsushi/tagbar
install_vim_package mbbill/undotree
install_vim_package milkypostman/vim-togglelist
install_vim_package ntpeters/vim-better-whitespace
install_vim_package plasticboy/vim-markdown
install_vim_package scrooloose/nerdcommenter
install_vim_package scrooloose/syntastic
install_vim_package shougo/deoplete.nvim # :UpdateRemotePlugins
install_vim_package shougo/neosnippet.vim
install_vim_package shougo/vimproc.vim "cd ~/.vim/bundle/vimproc.vim && make; cd -"
install_vim_package takac/vim-hardtime
install_vim_package terryma/vim-expand-region
install_vim_package tkhren/vim-fake
install_vim_package tpope/vim-eunuch
install_vim_package tpope/vim-fugitive
install_vim_package tpope/vim-repeat
install_vim_package tpope/vim-surround
install_vim_package vim-airline/vim-airline
install_vim_package vim-airline/vim-airline-themes
install_vim_package vim-ruby/vim-ruby
install_vim_package vim-scripts/AnsiEsc.vim
install_vim_package xolox/vim-colorscheme-switcher
install_vim_package xolox/vim-misc

echo 'Control-x: " fg\n"' >> ~/.inputrc

cat > ~/.vimrc <<"EOF"
execute pathogen#infect()
filetype plugin indent on
syntax on
set background=dark
set sessionoptions+=globals

let mapleader = "\<Space>"
let g:hardtime_default_on = 1

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
  nnoremap <leader>h :set relativenumber!<cr>

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
  vmap <leader>g "ay:%s/\C<c-r>a//g<left><left>

" fill the search bar with current text and allow to edit it
  vnoremap <leader>G y/<c-r>"
  nnoremap <leader>G viwy/<c-r>"

" prevent saving backup files
  set nobackup
  set noswapfile

" support all hex colors (e.g. for syntastic)
  set  t_Co=256

" incsearch.vim
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

" list mapped keys sorted. The asterisk means that the map is non recursive
  nnoremap <leader>M :redir! > /tmp/vim_keys.txt<cr>:silent verbose map<cr>:redir END<cr>
    \:-tabnew\|te cat /tmp/vim_keys.txt \| grep -v "Last set" \| grep -v "<Plug>"
    \ \| sort -k 1.4 \| less<cr>

" run saved command over file and reopen
  nnoremap <leader>kA :let g:File_cmd=''<left>
  nnoremap <leader>ka :!<c-r>=g:File_cmd<cr> %<cr>:e<cr>

" format json
  command! -range -nargs=0 -bar JsonTool <line1>,<line2>!python -m json.tool
  nnoremap <leader>kz :JsonTool<cr>
  vnoremap <leader>kz :'<,'>JsonTool<cr>

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

" reload all saved files without warnings
  set autoread
  autocmd FocusGained * checktime
  nnoremap <leader>e :checktime<cr>

set nowrap

autocmd Filetype markdown setlocal wrap

" improve indentation
  xnoremap <Tab> >gv
  xnoremap <S-Tab> <gv

" toggle distraction free mode
  nnoremap <silent> <leader>n :set nonumber<cr>:GitGutterDisable<cr>:set laststatus=0<cr>
    \ :let g:syntastic_auto_loc_list = 0<cr>:hi Folded ctermbg=black ctermfg=black<cr>
  nnoremap <silent> <leader>N :set number<cr>:GitGutterEnable<cr>:set laststatus=2<cr>
    \ :let g:syntastic_auto_loc_list = 2<cr>:hi Folded ctermbg=236 ctermfg=236<cr>

" fix c-b mapping to use with tmux (one page up)
  nnoremap <c-d> <c-b>

nnoremap <silent> <leader>s :if exists("g:syntax_on") \| syntax off \| else \| syntax enable \| endif<cr>

set nohlsearch
set autoindent
set clipboard=unnamedplus
set expandtab
set number
set shiftwidth=2
set softtabstop=2
set tabstop=2
set smartcase
set wildmenu

nnoremap <leader>kc :RandomColorScheme<cr>:call SetColors()<cr>:colorscheme<cr>

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

" airline
  set laststatus=2
  let g:airline_left_sep=''
  let g:airline_right_sep=''

" remove autoindentation when pasting
  set pastetoggle=<F2>

"  vim fugitive
  set diffopt+=vertical

" deoplete
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#auto_complete_start_length=1
  let g:deoplete#file#enable_buffer_path = 1
  call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
  inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
  inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<tab>"

let g:NERDSpaceDelims = 1
let g:rainbow_active = 1
let g:vim_json_syntax_conceal = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_folding_disabled = 1

" ctrlp
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$'
  nnoremap <leader>p :CtrlP %:p:h<cr> " CtrlP in file's dir
  nnoremap <leader>P :CtrlPMRUFiles<cr>
  nnoremap <leader>kpp :CtrlP /project<cr>
  nnoremap <leader>kpd :CtrlP ~/dev<cr>
  nnoremap <leader>kph :CtrlP ~<cr>
  nnoremap <leader>kpk :CtrlPClearAllCaches<cr>
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  if executable('ag')
    let g:ctrlp_user_command = 'ag %s -l --hidden --nocolor -g "" --ignore .git'
  endif

" syntastic
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_scss_checkers = ['stylelint']
  let g:syntastic_json_checkers=[]
  let g:syntastic_loc_list_height=3
  let g:syntastic_error_symbol = '•'
  let g:syntastic_style_error_symbol = '!?'
  nnoremap <leader>o :SyntasticToggleMode<cr>
  " Allow :lprev to work with empty location list, or at first location
  function! <SID>LocationPrevious()
    try
      lprev
    catch /:E553:/
      lfirst
    catch /:E\%(42\|776\):/
      echo "Location list empty"
    catch /.*/
      echo v:exception
    endtry
  endfunction
  " Allow :lnext to work with empty location list, or at last location
  function! <SID>LocationNext()
    try
      lnext
    catch /:E553:/
      lfirst
    catch /:E\%(42\|776\):/
      echo "Location list empty"
    catch /.*/
      echo v:exception
    endtry
  endfunction
  nnoremap <silent> <Plug>LocationPrevious :<C-u>exe 'call <SID>LocationPrevious()'<CR>
  nnoremap <silent> <Plug>LocationNext :<C-u>exe 'call <SID>LocationNext()'<CR>
  nmap <silent> e[  <Plug>LocationPrevious
  nmap <silent> e]  <Plug>LocationNext

map <leader>kw :tabnew <c-R>=expand("%:p:h") . "/" <cr>
map <leader>kW :e <c-R>=expand("%:p:h") . "/" <cr>

vnoremap <leader>ku y:%s/\C<c-r>"//gn<cr>

" sort indent block. requires nmap. requires 2 plugins.
  nmap <leader>kl vii:sort<cr>

nnoremap <leader>ku viwy:%s/\C<c-r>"//gn<cr>
nnoremap <leader>x :set noeol<cr>:set binary<cr>:w<cr>:set nobinary<cr>
nnoremap <leader>ko :mksession! ~/mysession.vim<cr>:qa<cr>
au BufNewFile,BufRead *.ejs set filetype=html

" move up/down from the beginning/end of lines
  set ww+=<,>

" useful maps for macros
  nnoremap <leader>d @d
  nnoremap W @q
  nnoremap <leader>W _v$<left>y:q<cr>:let @="<c-r>""<home><right><right><right><right><right>
  nnoremap <leader>Q :!cat ~/.vim-macros > /tmp/macros;
    \ cat ~/.vim-macros-custom >> /tmp/macros<cr><cr>:tabnew /tmp/macros<cr>
  nnoremap <leader>E :tabnew ~/.vim-macros-custom<cr>

nnoremap <leader>kv :%s/\t/  /g<cr>
vnoremap <F4> :sort<cr>
inoremap <c-e> <esc>A
inoremap <c-a> <esc>I
vnoremap <silent> y y`]
nnoremap <silent> p p`]
vnoremap <silent> p pgvy`]

" delete from cursor to end of line
  inoremap <C-Del> <C-\><C-O>D

" don't have to press the extra key when exiting the terminal
  augroup terminal
    autocmd!
    autocmd TermClose * close
  augroup end

" neosnippet
  " Enter in select mode: gh
  imap <c-l>     <Plug>(neosnippet_expand_or_jump)
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
   \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  if has('conceal')
    set conceallevel=2 concealcursor=niv
  endif
  let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim-snippets'
  let g:neosnippet#disable_runtime_snippets={'c' : 1, 'cpp' : 1}
  let g:neosnippet#expand_word_boundary=1
  imap <c-d>     <Plug>(neosnippet_jump)
  smap <c-d>     <Plug>(neosnippet_jump)

" save file shortcuts
  nmap <c-s> :update<esc>
  inoremap <c-s> <esc>:update<cr>

" copy - paste between files and VMs
  vmap <leader>fy "uy:-tabnew /vm-shared/_vitmp<cr>ggVG"up:x<cr>
  nmap <leader>fp :-tabnew /vm-shared/_vitmp<cr>gg_vG$<left>"uy:q!<cr>"up
  vmap <leader>fp <c-c>:-tabnew /vm-shared/_vitmp<cr>ggvG$<left>"uy:q!<cr>gv"up

" lines in files
  nnoremap <leader>kr :-tabnew\|te ( F(){ find $1 -type f \| xargs wc -l \| sort -rn \|
  \ sed "s\|$1\|\|" \| sed "1i _" \| sed "1i $1" \| sed "1i _" \| sed '4d' \| less; }
  \ && F <c-R>=expand("%:p:h")<cr>/ )<left><left>

" color tree
  nnoremap <leader>kt :-tabnew\|te tree -a -C <c-R>=expand("%:p:h")<cr> \|
  \ less -R<c-left><c-left><c-left><left>

" grep current file
  let g:GrepCF_fn = ':w! /tmp/current_vim<cr>:-tabnew\|te
    \ Grep() { printf "<c-r>=expand("%")<cr>\n\n"; grep --color=always "$@" /tmp/current_vim;
    \ printf "\n----\n\nlines: "; grep -in "$@" /tmp/current_vim \| wc -l; echo ""; }
    \ && GrepAndLess() { Grep "$@" \| less -R; } && GrepAndLess '
  execute 'nnoremap <leader>ky ' . g:GrepCF_fn . ' -i ""<left>'
  execute 'vnoremap <leader>ky y' . g:GrepCF_fn . ' -i "<c-r>""<left>'

" fast grep
  let g:FastGrep_fn = ':-tabnew\|te
    \ Grep() { grep -rn --color=always "$@"; printf "\n\n\n----\n\n\n"; grep --color=always -rl "$@"; }
    \ && Grep -i "<c-r>"" <c-r>=g:Fast_grep<cr> \| less -R<c-left><c-left><left><left><left><c-left><left><left>'
  let g:Fast_grep=''
  nnoremap <leader>B :let g:Fast_grep=''<left>
  execute 'vnoremap <leader>b y' . g:FastGrep_fn
  execute 'nnoremap <leader>b" vi"y' . g:FastGrep_fn
  execute 'nnoremap <leader>bw viwy' . g:FastGrep_fn
  execute 'nnoremap <leader>bb vy' . g:FastGrep_fn
  execute 'nnoremap <leader>bf vy' . g:FastGrep_fn . '<c-left><left><left><bs>/<c-R>=expand("%:t")<cr>'

" improve the 'preview window' behaviour
  autocmd CompleteDone * pclose " close when done
  set splitbelow " move to the bottom

" add and remove variable at the end of line, this value would be overriden in the custom section
  let g:Custom_flag='FOO'
  nnoremap <leader>kh A<c-r>=g:Custom_flag<cr>
  nnoremap <leader>kH V:s`<c-r>=g:Custom_flag<cr>``g<cr>

" vim-expand-region
  vmap v <Plug>(expand_region_expand)
  vmap <c-v> <Plug>(expand_region_shrink)

" convenience indentation for copy-paste
  " autocmd Filetype EXTENSION setlocal softtabstop=2 tabstop=2 shiftwidth=2
  " autocmd Filetype EXTENSION setlocal softtabstop=4 tabstop=4 shiftwidth=4
  " autocmd BufRead,BufEnter /path/to/project/*.{js} setlocal softtabstop=4 tabstop=4 shiftwidth=4

" quickly move to lines
  nnoremap <cr> G
  nnoremap <bs> gg

" undo tree
  nnoremap <leader>m :UndotreeShow<cr><c-w><left>

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

" easymotion
  nmap , <Plug>(easymotion-overwin-f)

" tagbar
  nmap <leader>v :TagbarToggle<cr>
  let g:tagbar_type_make = {'kinds':['m:macros', 't:targets']}
  let g:tagbar_type_markdown = {'ctagstype':'markdown','kinds':['h:Heading_L1','i:Heading_L2','k:Heading_L3']}

" move by visual lines (for wrapped lines)
  map <down> gj
  map <up> gk

" highlight last inserted text
  nnoremap gV `[v`]

" fzf maps
  nnoremap <leader>ja :Ag!<cr>
  nnoremap <leader>jc :Commands!<cr>
  nnoremap <leader>jg :GFiles?<cr>
  nnoremap <leader>jh :History:!<cr>
  nnoremap <leader>jj :Lines!<cr>
  nnoremap <leader>jl :BLines!<cr>
  nnoremap <leader>jm :Marks!<cr>
  nnoremap <leader>jM :Maps!<cr>
  nnoremap <leader>jt :Tags!<cr>
  nnoremap <leader>jw :Windows!<cr>
  nnoremap <leader>jf :Filetypes!<cr>
  nnoremap <leader>je :AnsiEsc<cr>

" disable deop;deoplete
  nnoremap <leader>jd :call deoplete#disable()<cr>
  nnoremap <leader>jD :call deoplete#enable()<cr>

" related working dir
  let g:rooter_manual_only = 1
  nnoremap <leader>,, :pwd<cr>
  nnoremap <leader>,. :cd <c-r>=expand(getcwd())<cr>/
  nnoremap <leader>,f :cd <c-r>=expand("%:p:h")<cr>/
  nnoremap <leader>,h :cd ~/
  nnoremap <leader>,p :cd /project/
  nnoremap <leader>,r :Rooter<cr>

" limelight
  let g:limelight_conceal_ctermfg = 'black'
  let g:limelight_bop = '^'
  let g:limelight_eop = '$'
  nnoremap <leader>zl :Limelight!!<cr>
  nnoremap <leader>zL :let g:limelight_paragraph_span = <left><right>

" http://vim.wikia.com/wiki/File:Xterm-color-table.png
function! SetColors()
  hi DiffAdd ctermbg=22
  hi DiffChange ctermbg=52
  hi DiffText ctermbg=red
  hi NonText ctermfg=black
  hi Error ctermbg=lightred ctermfg=black
  hi Folded ctermbg=236 ctermfg=236
  hi IncSearch gui=NONE ctermbg=black ctermfg=red
  hi MatchParen ctermfg=black ctermbg=white
  hi Search cterm=NONE ctermfg=black ctermbg=white
  hi SpellBad ctermbg=lightred ctermfg=black
  hi TabLine ctermfg=gray ctermbg=black
  hi TabLineFill ctermfg=black ctermbg=black
  " better completion menu colors
    hi Pmenu ctermfg=white ctermbg=17
    hi PmenuSel ctermfg=white ctermbg=29
  hi link TabNum Special
  hi link SyntasticErrorSign SignColumn
  hi link SyntasticWarningSign SignColumn
  hi link SyntasticStyleErrorSign SignColumn
  hi link SyntasticStyleWarningSign SignColumn
  hi Visual ctermfg=white ctermbg=17
endfunction

call SetColors()
EOF

cat >> ~/.bashrc <<"EOF"
export EDITOR=nvim
export TERM=xterm-256color
source ~/.bash_aliases # some aliases depend on $EDITOR
EOF

cat >> ~/.bash_aliases <<"EOF"
n() {
  if [[ -z "$1" ]]; then DIRECTORY=.; else DIRECTORY="$1"; fi
  if [ -d "$DIRECTORY" ]; then
    DEPTH=1; FILE="";
    while [ $DEPTH -lt 100 ]; do
      FILE=$(find $DIRECTORY -mindepth $DEPTH -maxdepth $DEPTH -type f | head -n 1)
      if [[ ! -z $FILE ]]; then break; else DEPTH=$((DEPTH + 1)); fi
    done
  else FILE="$DIRECTORY"; fi
  nvim "$FILE"
}
alias nn='nvim -n -u NONE -i NONE -N' # nvim without vimrc, plugins, syntax, etc
alias NVimSession='nvim -S ~/mysession.vim'
alias CheckVimSnippets='nvim ~/.vim/bundle/vim-snippets/snippets'
EOF

mkdir -p ~/.vim-snippets

rm -rf /tmp/tmp.*

cat > ~/.vim-macros <<"EOF"
Macros file.
This file is automatically generated. For custom macros, add them in ~/.vim-macros-custom
You can open that file in vim with <leader>E

EOF

touch ~/.vim-macros-custom

install_vim_package junegunn/fzf "cd ~/.vim/bundle/fzf && ./install --all; cd -"
install_vim_package junegunn/fzf.vim
__add_n_completion() {
  ALL_CMDS="n sh node ll"; sed -i "s|nvim $ALL_CMDS |nvim |; s|nvim |nvim $ALL_CMDS |" "$1";
  DIR_CMDS='mkdir tree'; sed -i "s|pushd $DIR_CMDS |pushd |; s|pushd |pushd $DIR_CMDS |" "$1";
}
__add_n_completion /home/vagrant/.vim/bundle/fzf/shell/completion.bash
__add_n_completion /home/vagrant/.fzf/shell/completion.bash
cat >> ~/.bash_aliases <<"EOF"
NFZF() { nvim -R -c "set foldlevel=20" -c "Line!" -; } # useful to pipe to this cmd
Tree() { tree -a $@ -C -I "node_modules|.git" | nvim -R -c "AnsiEsc" -c "set foldlevel=20" -; }
EOF

# vim END
