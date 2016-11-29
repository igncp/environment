# vim START

install_vim_package() {
  REPO=$1
  DIR=$(echo $REPO | sed -r "s|.+/(.+)|\1|") # foo/bar => bar
  EXTRA_CMD=$2
  if [ ! -d ~/.vim/bundle/"$DIR" ]; then
    git clone https://github.com/$REPO.git ~/.vim/bundle/"$DIR"
    if [[ ! -z $EXTRA_CMD ]]; then eval $EXTRA_CMD; fi
  fi
}

mkdir -p ~/.vim/autoload/ ~/.vim/bundle
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
  curl https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim \
    > ~/.vim/autoload/pathogen.vim
fi

if ! type nvim > /dev/null 2>&1 ; then
  echo "installing neovim"
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt-get update && sudo apt-get install -y neovim
  sudo apt-get install -y python3-pip
  sudo pip3 install neovim
  mkdir -p ~/.config
  rm -rf ~/.config/nvim
  ln -s ~/.vim ~/.config/nvim
  ln -s ~/.vimrc ~/.config/nvim/init.vim
  git config --global core.editor "nvim"
fi

install_vim_package airblade/vim-gitgutter
install_vim_package ctrlpvim/ctrlp.vim
install_vim_package easymotion/vim-easymotion
install_vim_package elzr/vim-json
install_vim_package evidens/vim-twig
install_vim_package haya14busa/incsearch.vim
install_vim_package honza/vim-snippets
install_vim_package jelera/vim-javascript-syntax
install_vim_package jiangmiao/auto-pairs
install_vim_package luochen1990/rainbow
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
install_vim_package tpope/vim-fugitive
install_vim_package tpope/vim-repeat
install_vim_package tpope/vim-surround
install_vim_package vim-airline/vim-airline
install_vim_package vim-airline/vim-airline-themes
install_vim_package vim-ruby/vim-ruby
install_vim_package vim-scripts/cream-showinvisibles
install_vim_package yggdroot/indentLine

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
  nnoremap <F10> :buffers<CR>:buffer<Space>
  nnoremap <silent> <F12> :bn<CR>
  nnoremap <silent> <S-F12> :bp<CR>

" don't copy when using del
  vnoremap <Del> "_d
  nnoremap <Del> "_d

" numbers maps
  set relativenumber
  nnoremap <leader>h :set relativenumber!<CR>

" open file in same dir
  map ,e :e <C-R>=expand("%:p:h") . "/" <CR>

" replace selection
  vmap <leader>g y:%s/\C<C-r>"//g<left><left>

" prevent saving backup files
  set nobackup
  set noswapfile

" support all hex colors (e.g. for syntastic)
  set  t_Co=256

" incsearch.vim
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

" move lines up and down
  nnoremap <C-j> :m .+1<CR>==
  nnoremap <C-k> :m .-2<CR>==
  inoremap <C-j> <Esc>:m .+1<CR>==gi
  inoremap <C-k> <Esc>:m .-2<CR>==gi
  vnoremap <C-j> :m '>+1<CR>gv=gv
  vnoremap <C-k> :m '<-2<CR>gv=gv

" remove trailing spaces
  nmap <leader>t :%s/\s\+$<CR><C-o>

" folding
  set foldmethod=indent
  set nofoldenable
  set fml=0
  set nowrap
  hi Folded ctermbg=236

" improve indentation
  xnoremap <Tab> >gv
  xnoremap <S-Tab> <gv

" to easily copy with the mouse
  nnoremap <leader>n :set number!<CR>:GitGutterToggle<CR>

" fix c-b mapping to use with tmux (one page up)
  nnoremap <C-d> <c-b>

set nohlsearch
set autoindent
set clipboard=unnamedplus
set cursorline
set expandtab
set number
set shiftwidth=2
set softtabstop=2
set tabstop=2
set smartcase
set wildmenu

" better completion menu colors
  highlight Pmenu ctermfg=white ctermbg=17
  highlight PmenuSel ctermfg=white ctermbg=29

" better matching color
  hi MatchParen ctermfg=black

" ignore case in searches
  set ic

nnoremap <C-w>v :vsplit<CR><C-w><right>
nnoremap <leader>w :set wrap!<CR>
nnoremap <leader>a ggvG$
nnoremap <leader>i :set list!<CR>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>

" airline
  set laststatus=2
  let g:airline_left_sep=''
  let g:airline_right_sep=''

" remove autoindentation when pasting
  set pastetoggle=<F2>

" deoplete
  let g:deoplete#enable_at_startup = 1

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
  nnoremap <leader>p :CtrlP %:p:h<CR> " CtrlP in file's dir

" syntastic
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_javascript_checkers = ['eslint']
  let g:syntastic_typescript_checkers = ['tsc', 'tslint']
  let g:syntastic_scss_checkers = ['stylelint']
  let g:syntastic_json_checkers=[]
  highlight link SyntasticErrorSign SignColumn
  highlight link SyntasticWarningSign SignColumn
  highlight link SyntasticStyleErrorSign SignColumn
  highlight link SyntasticStyleWarningSign SignColumn
  let g:syntastic_error_symbol = '❌'
  let g:syntastic_style_error_symbol = '⁉️'
  hi Error ctermbg=lightred ctermfg=black
  hi SpellBad ctermbg=lightred ctermfg=black
  nnoremap <leader>o :SyntasticToggleMode<CR>

map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
vnoremap <leader>ku y:%s/\C<C-r>"//gn<CR>
nnoremap <leader>ku viwy:%s/\C<C-r>"//gn<CR>
nnoremap <leader>; :
nnoremap <leader>ko :mksession! ~/mysession.vim<CR>:qa<CR>
au BufNewFile,BufRead *.ejs set filetype=html

" move up/down from the beginning/end of lines
  set ww+=<,>

" change to current file directory
  nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

" run macro on d
  nnoremap <leader>d @d

" sort lines
  vmap <F3> :sort<CR>

inoremap <C-e> <Esc>A
inoremap <C-a> <Esc>I

" vp doesn't replace paste buffer
  function! RestoreRegister()
    let @" = s:restore_reg
    return ''
  endfunction
  function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
  endfunction
  vmap <silent> <expr> p <sid>Repl()

" neosnippet
  imap <C-l>     <Plug>(neosnippet_expand_or_jump)
  smap <C-l>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-l>     <Plug>(neosnippet_expand_target)
  imap <expr><TAB>
   \ pumvisible() ? "\<C-n>" :
   \ neosnippet#expandable_or_jumpable() ?
   \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
   \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  if has('conceal')
    set conceallevel=2 concealcursor=niv
  endif
  let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
  let g:neosnippet#disable_runtime_snippets={'c' : 1, 'cpp' : 1,}

" save file shortcuts
  nmap <C-s> :update<Esc>
  inoremap <C-s> <Esc>:update<CR>

" copy - paste between files and vms
  vmap <leader>fy :w! /vm-shared/_vitmp<CR>
  nmap <leader>fp :r! cat /vm-shared/_vitmp<CR>
  vmap <leader>fp d:r! cat /vm-shared/_vitmp<CR>

" lines in files
  nnoremap <leader>kr :tabnew\|te ( F(){ find $1 -type f \| xargs wc -l \| sort -rn \|
  \ sed "s\|$1\|\|" \| sed "1i _" \| sed "1i $1" \| sed "1i _" \| sed '4d' \| less; }
  \ && F <C-R>=expand("%:p:h")<CR>/ )<left><left>

" color tree
  nnoremap <leader>kt :tabnew\|te tree -a -C <C-R>=expand("%:p:h")<CR> \|
  \ less -R<c-left><c-left><c-left><left>

" grep current file
  nnoremap <leader>ky :grep -oh "" %<left><left><left>

" fast grep
  let g:Fast_grep=''
  nnoremap <leader>B :let g:Fast_grep=''<left>
  vnoremap <leader>b y:tabnew\|te
  \ Grep() { grep -rin --color=always "$@"; printf "\n\n\n----\n\n\n"; grep --color=always -ril "$@"; }
  \ && Grep "" \| less -R<c-left><c-left><c-left><left><left><C-r>"<right><right><c-r>=g:Fast_grep<CR>

" improve the 'preview window' behaviour
  autocmd CompleteDone * pclose " close when done
  set splitbelow " move to the bottom

" vim-expand-region
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)

" search and replace (using cs on first match and n.n.n.)
  vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
      \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
  omap s :normal vs<CR>

" autocmd Filetype sh setlocal softtabstop=2 tabstop=2 shiftwidth=2

" quickly move to lines
  nnoremap <CR> G
  nnoremap <BS> gg
" undo tree
  nnoremap <leader>m :UndotreeShow<CR><C-w><left>

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
  nnoremap <C-h> :execute "tabmove" tabpagenr() - 2 <CR>
  nnoremap <C-l> :execute "tabmove" tabpagenr() + 1 <CR>
  nnoremap <C-t> :tabnew<CR>
  nnoremap <C-d> :tabclose<CR>
  hi TabLine ctermfg=gray ctermbg=black
  hi TabLineFill ctermfg=black ctermbg=black
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
      highlight link TabNum Special
  endif
EOF

cat >> ~/.bashrc <<"EOF"
export EDITOR=nvim
export TERM=xterm-256color
source ~/.bash_aliases # some aliases depend on $EDITOR
EOF

cat >> ~/.bash_aliases <<"EOF"
alias nv='nvim'
alias NVimSession='nvim -S ~/mysession.vim'
EOF

# vim END
