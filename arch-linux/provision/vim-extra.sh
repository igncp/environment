# vim-extra START

install_vim_package() {
  REPO=$1
  DIR=$(echo $REPO | sed -r "s|.+/(.+)|\1|") # foo/bar => bar
  EXTRA_CMD=$2
  if [ ! -d ~/.vim/bundle/"$DIR" ]; then
    echo "installing $REPO"
    git clone --depth=1 https://github.com/$REPO.git ~/.vim/bundle/"$DIR"
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
  sudo chmod -R 755 /usr/lib/python3.7 # fix the deoplete issue
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
install_vim_package junegunn/vim-easy-align
install_vim_package kana/vim-textobj-indent
install_vim_package kana/vim-textobj-user
install_vim_package luochen1990/rainbow
install_vim_package majutsushi/tagbar
install_vim_package martinda/Jenkinsfile-vim-syntax
install_vim_package mbbill/undotree
install_vim_package milkypostman/vim-togglelist
install_vim_package ntpeters/vim-better-whitespace
install_vim_package plasticboy/vim-markdown
install_vim_package scrooloose/nerdcommenter
install_vim_package shougo/deoplete.nvim # :UpdateRemotePlugins
install_vim_package shougo/neoinclude.vim
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
install_vim_package w0rp/ale
install_vim_package xolox/vim-colorscheme-switcher
install_vim_package xolox/vim-misc

cat >> ~/.vimrc <<"EOF"
execute pathogen#infect()
let g:hardtime_default_on = 1

" incsearch.vim
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

" format json
  command! -range -nargs=0 -bar JsonTool <line1>,<line2>!python -m json.tool
  nnoremap <leader>kz :JsonTool<cr>
  vnoremap <leader>kz :'<,'>JsonTool<cr>

" toggle distraction free mode
  nnoremap <silent> <leader>n :set nonumber<cr>:GitGutterDisable<cr>:set laststatus=0<cr>
    \ :hi Folded ctermbg=black ctermfg=black<cr>
  nnoremap <silent> <leader>N :set number<cr>:GitGutterEnable<cr>:set laststatus=2<cr>
    \ :hi Folded ctermbg=236 ctermfg=236<cr>

nnoremap <leader>kc :RandomColorScheme<cr>:call SetColors()<cr>:colorscheme<cr>

" airline
  set laststatus=2
  let g:airline_theme='minimalist'
  let g:airline_left_sep=''
  let g:airline_right_sep=''

"  vim fugitive
  set diffopt+=vertical

" deoplete
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#auto_complete_start_length=1
  let g:deoplete#file#enable_buffer_path = 1
  call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
  inoremap <expr><c-j> pumvisible() ? "\<c-n>" : "\<c-j>"
  inoremap <expr><c-k> pumvisible() ? "\<c-p>" : "\<c-k>"

let g:NERDSpaceDelims = 1
let g:rainbow_active = 0
let g:vim_json_syntax_conceal = 0

" markdown
  let g:vim_markdown_auto_insert_bullets = 0
  let g:vim_markdown_new_list_item_indent = 0
  let g:vim_markdown_conceal = 0
  let g:tex_conceal = ""
  let g:vim_markdown_math = 1
  let g:vim_markdown_folding_disabled = 1
  autocmd Filetype markdown set conceallevel=0

" ctrlp
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$'
  nnoremap <leader>p :CtrlP %:p:h<cr> " CtrlP in file's dir
  nnoremap <leader>P :CtrlPMRUFiles<cr>
  nnoremap <leader>zP :let g:CustomZPDir='<c-r>=expand(getcwd())<cr>'
  nnoremap <leader>zp :CtrlP <c-r>=expand(g:CustomZPDir)<cr><cr>
  nnoremap <leader>kpp :CtrlP /project<cr>
  nnoremap <leader>kpd :CtrlP ~/dev<cr>
  nnoremap <leader>kph :CtrlP ~<cr>
  nnoremap <leader>kpk :CtrlPClearAllCaches<cr>
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  if executable('ag')
    let g:ctrlp_user_command = 'ag %s -l --hidden --nocolor -g "" --ignore .git'
  endif

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

" ale
  let g:ale_lint_on_text_changed = 'never'
  let g:ale_sign_error = 'E '
  let g:ale_sign_warning = 'W '
  let g:ale_set_highlights = 0
  let g:ale_open_list = 0
  let g:ale_keep_list_window_open = 0
  let g:ale_list_window_size = 0
  let g:ale_set_loclist = 0
  let g:ale_set_quickfix = 0
  nmap <silent> e[ <Plug>(ale_previous_wrap)
  nmap <silent> e]  <Plug>(ale_next_wrap)

" useful maps for macros
  nnoremap <leader>d @d
  nnoremap W @q
  nnoremap <leader>zw :nnoremap W @
  nnoremap <leader>zW :nnoremap W @q<cr>
  " run this macro from the macros file, there should be at least two tabs opened
  nnoremap <leader>WWW _v$<left>y:q<cr>:let @="<c-r>""<home><right><right><right><right><right>
  nnoremap <leader>Q :!cat ~/.vim-macros > /tmp/macros; printf "\n\n\n" >> /tmp/macros;
    \ cat /project/provision/vim-macros-custom >> /tmp/macros<cr><cr>:tabnew /tmp/macros<cr>
  nnoremap <leader>E :tabnew /project/provision/vim-macros-custom<cr>
  function! ReplaceWeirdCharactersForMacros()
    let replacements = {
      \ "\<C-[>": '\\<esc>',
      \ "\<C-M>": '\\<cr>',
      \ "b": '\\<esc>',
      \ "": '\\<esc>',
      \ "k": '\\<bs>'
      \}
    for [a, b] in items(replacements)
      execute "s/" . a . "/" . b . "/ge"
    endfor
  endfunction
  nnoremap <leader>za :call ReplaceWeirdCharactersForMacros()<cr>

" neosnippet
  " Enter in select mode: gh
  imap <c-l>     <Plug>(neosnippet_expand_or_jump)
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
   \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  if has('conceal')
    set conceallevel=2 concealcursor=niv
  endif
  let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim-snippets,/project/vim-custom-snippets'
  let g:neosnippet#disable_runtime_snippets={'c' : 1, 'cpp' : 1}
  let g:neosnippet#expand_word_boundary=1
  imap <c-d>     <Plug>(neosnippet_jump)
  smap <c-d>     <Plug>(neosnippet_jump)

" save file shortcuts
  nnoremap <leader>ks :silent exec "!mkdir -p <c-R>=expand("%:p:h")<cr>"<cr>:w<cr>:silent exec ":CtrlPClearAllCaches"<cr>

" copy - paste between files and VMs
  vmap <leader>fy "uy:-tabnew /tmp/vim-shared<cr>ggVG"up:x<cr>
  nmap <leader>fp :-tabnew /tmp/vim-shared<cr>gg_vG$<left>"uy:q!<cr>"up
  vmap <leader>fp <c-c>:-tabnew /tmp/vim-shared<cr>ggvG$<left>"uy:q!<cr>gv"up

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
    \ && Grep <c-r>=g:Fast_grep_opts<cr> "<c-r>"" <c-r>=g:Fast_grep<cr> \| less -R<c-left><c-left><left><left><left><c-left><left><left>'
  let g:Fast_grep=''
  let g:Fast_grep_opts='-i'
  nnoremap <leader>BB :let g:Fast_grep=''<left>
  nnoremap <leader>BV :let g:Fast_grep_opts='-i '<left>
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

" don't have to press the extra key when exiting the terminal (nvim)
  augroup terminal
    autocmd!
    autocmd TermClose * close
  augroup end
  autocmd TermOpen * startinsert

" convenience indentation for copy-paste
  " autocmd Filetype EXTENSION setlocal softtabstop=2 tabstop=2 shiftwidth=2
  " autocmd Filetype EXTENSION setlocal softtabstop=4 tabstop=4 shiftwidth=4
  " autocmd BufRead,BufEnter /path/to/project/*.{js} setlocal softtabstop=4 tabstop=4 shiftwidth=4

" undo tree
  nnoremap <leader>mm :UndotreeShow<cr><c-w><left>

" easymotion
  nmap , <Plug>(easymotion-overwin-f)

" tagbar
  nmap <leader>v :TagbarToggle<cr>
  let g:tagbar_type_make = {'kinds':['m:macros', 't:targets']}
  let g:tagbar_type_markdown = {'ctagstype':'markdown','kinds':['h:Heading_L1','i:Heading_L2','k:Heading_L3']}

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

" disable deoplete
  nnoremap <leader>jd :call deoplete#disable()<cr>
  nnoremap <leader>jD :call deoplete#enable()<cr>

" easy align
  xmap ga <Plug>(EasyAlign)
  nmap ga <Plug>(EasyAlign)

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
alias nb='nvim -n -u ~/.base-vimrc -i NONE -N' # nvim with base vimrc
alias NVimSession='nvim -S ~/mysession.vim'
alias CheckVimSnippets='nvim ~/.vim/bundle/vim-snippets/snippets'
# https://vi.stackexchange.com/a/277
NProfile() {
  nvim --startuptime /tmp/nvim-profile-log.txt "$@"
  cat /tmp/nvim-profile-log.txt  | grep '^[0-9]' | sort -r -k 2 | less
}
EOF

mkdir -p ~/.vim-snippets

# this snippets will not be overriden by the provision
# they should be changed manually
mkdir -p /project/vim-custom-snippets/

rm -rf /tmp/tmp.*

cat > ~/.vim-macros <<"EOF"
Macros file.
This file is automatically generated. For custom macros, add them in /project/provision/vim-macros-custom
You can open that file in vim with <leader>E

EOF

touch /project/provision/vim-macros-custom

install_vim_package junegunn/fzf "cd ~/.vim/bundle/fzf && ./install --all; cd -"
install_vim_package junegunn/fzf.vim
__add_n_completion() {
  ALL_CMDS="n sh RsyncDelete node l nn ll"; sed -i "s|nvim $ALL_CMDS |nvim |; s|nvim |nvim $ALL_CMDS |" "$1";
  DIR_CMDS='mkdir tree'; sed -i "s|pushd $DIR_CMDS |pushd |; s|pushd |pushd $DIR_CMDS |" "$1";
}
__add_n_completion /home/"$USER"/.vim/bundle/fzf/shell/completion.bash
__add_n_completion /home/"$USER"/.fzf/shell/completion.bash
cat >> ~/.bash_aliases <<"EOF"
NFZF() { nvim -R -c "set foldlevel=20" -c "Line!" -; } # useful to pipe to this cmd
Tree() { tree -a $@ -C -I "node_modules|.git" | nvim -R -c "AnsiEsc" -c "set foldlevel=20" -; }
EOF

cat >> ~/.vimrc <<"EOF"
" from fzf.vim
function! s:key_sink(line)
  let key = matchstr(a:line, '^\S*')
  redraw
  call feedkeys(substitute(key, '<[^ >]\+>', '\=eval("\"\\".submatch(0)."\"")', 'g'))
endfunction
function! SpecialMaps()
  let file_content = system('cat ~/.special-vim-maps-from-provision.txt')
  let source_list = split(file_content, '\n')
  let options_dict = {
    \ 'options': ' --prompt "Maps (n)> " --ansi --no-hscroll --query "<Space>zm" --nth 1,..',
    \ 'source': source_list,
    \ 'sink': function('s:key_sink'),
    \ 'name': 'maps'}

  call fzf#run(options_dict)
endfunction

nnoremap <c-f> :call SpecialMaps()<cr>
inoremap <c-f> <c-c>:call SpecialMaps()<cr>
EOF

# these maps will be present in a fzf list (apart from working normally)
# the must begin with <leader>zm (where <leader> == <Space>)
add_special_vim_map() {
  MAP_KEYS_AFTER_LEADER="$1"
  MAP_END="$2"
  MAP_COMMENT="$3"

  echo "nnoremap <leader>zm$MAP_KEYS_AFTER_LEADER $MAP_END" >> ~/.vimrc
  echo "<Space>zm$MAP_KEYS_AFTER_LEADER -- $MAP_COMMENT" >> ~/.special-vim-maps-from-provision.txt
}

echo "" > ~/.special-vim-maps-from-provision.txt

add_special_vim_map "renameexisting" $':Rename <c-r>=expand("%:t")<cr>' 'rename existing file'
add_special_vim_map "showabsolutepath" $':echo expand("%:p")<cr>' 'show absolute path of file'
add_special_vim_map "showrelativepath" $':echo @%<cr>' 'show relative path of file'

if [ -f /project/scripts/create_vim_snippets.sh ]; then
  sh /project/scripts/create_vim_snippets.sh
else
  echo "/project/scripts/create_vim_snippets.sh file missing"
fi

# vim-extra END
