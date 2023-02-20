# vim-extra START

# - depends on 'python' provision

mkdir -p ~/.vim/lua
echo '' > ~/.vim/lua/extra_beginning.lua

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

install_system_package neovim nvim

if [ ! -f ~/.check-files/neovim ] ; then
  pip3 install neovim
  mkdir -p ~/.config
  rm -rf ~/.config/nvim
  rm -rf ~/.vim/init.vim
  ln -s ~/.vim ~/.config/nvim
  ln -s ~/.vimrc ~/.config/nvim/init.vim
  touch ~/.check-files/neovim
fi
git config --global core.editor nvim # faster than sed

install_vim_package airblade/vim-gitgutter # https://github.com/airblade/vim-gitgutter
install_vim_package andrewRadev/splitjoin.vim # gS, gJ
install_vim_package bogado/file-line # https://github.com/bogado/file-line
install_vim_package ctrlpvim/ctrlp.vim # https://github.com/ctrlpvim/ctrlp.vim
install_vim_package elzr/vim-json # https://github.com/elzr/vim-json
install_vim_package google/vim-searchindex # https://github.com/google/vim-searchindex
install_vim_package haya14busa/incsearch.vim # https://github.com/haya14busa/incsearch.vim
install_vim_package honza/vim-snippets "find ~/.vim/bundle/vim-snippets/snippets/ -type f | xargs sed -i 's|:\${VISUAL}||'"
install_vim_package jiangmiao/auto-pairs # https://github.com/jiangmiao/auto-pairs
install_vim_package junegunn/limelight.vim # https://github.com/junegunn/limelight.vim
install_vim_package junegunn/vim-peekaboo # https://github.com/junegunn/vim-peekaboo
install_vim_package liuchengxu/vista.vim # https://github.com/liuchengxu/vista.vim
install_vim_package mbbill/undotree # https://github.com/mbbill/undotree
install_vim_package ntpeters/vim-better-whitespace # https://github.com/ntpeters/vim-better-whitespace
install_vim_package plasticboy/vim-markdown # https://github.com/plasticboy/vim-markdown
install_vim_package rhysd/clever-f.vim # https://github.com/rhysd/clever-f.vim
install_vim_package ryanoasis/vim-devicons # if not supported, add in custom: rm -rf ~/.vim/bundle/vim-devicons/*
install_vim_package scrooloose/nerdcommenter # https://github.com/scrooloose/nerdcommenter
install_vim_package terryma/vim-expand-region # https://github.com/terryma/vim-expand-region
install_vim_package tommcdo/vim-exchange # https://github.com/tommcdo/vim-exchange
install_vim_package tpope/vim-eunuch # https://github.com/tpope/vim-eunuch
install_vim_package tpope/vim-fugitive # https://github.com/tpope/vim-fugitive
install_vim_package tpope/vim-repeat # https://github.com/tpope/vim-repeat
install_vim_package tpope/vim-surround # https://github.com/tpope/vim-surround
install_vim_package vim-scripts/AnsiEsc.vim # https://github.com/vim-scripts/AnsiEsc.vim

cat >> ~/.vimrc <<"EOF"
execute pathogen#infect()
lua require("extra_beginning")

" ctrlp
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_show_hidden = 1
  nnoremap <leader>p :CtrlP %:p:h<cr> " CtrlP in file's dir
  nnoremap <leader>P :CtrlPMRUFiles<cr>
  nnoremap <leader>kpp :CtrlP ~/project<cr>
  nnoremap <leader>kpk :CtrlPClearAllCaches<cr>
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  let g:ctrlp_user_command = 'ag %s -l --hidden --ignore "\.git/*" --nocolor -g ""'
  nnoremap <leader>O :let g:CustomZPDir='<c-r>=expand(getcwd())<cr>'
  nnoremap <leader>o :CtrlP <c-r>=expand(g:CustomZPDir)<cr><cr>
  if exists("g:CustomZPDir") == 0
    let g:CustomZPDir=getcwd()
  endif

" lines in files
  nnoremap <leader>kr :-tabnew\|te ( F(){ find $1 -type f \| xargs wc -l \| sort -rn \|
  \ sed "s\|$1\|\|" \| sed "1i _" \| sed "1i $1" \| sed "1i _" \| sed '4d' \| less; }
  \ && F <c-R>=expand("%:p:h")<cr>/ )<left><left>

" don't have to press the extra key when exiting the terminal (nvim)
  augroup terminal
    autocmd!
    autocmd TermClose * close
  augroup end
  autocmd TermOpen * startinsert
EOF

cat >> ~/.shellrc <<"EOF"
export EDITOR=nvim
export TERM=xterm-256color
source "$HOME"/.shell_aliases # some aliases depend on $EDITOR
EOF

cat >> ~/.shell_aliases <<"EOF"
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
alias XargsNvim='xargs nvim -p'
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
mkdir -p ~/project/vim-custom-snippets/

cat > ~/.vim-macros <<"EOF"
Macros file.
This file is automatically generated. For custom macros, add them in ~/project/provision/vim-macros-custom
You can open this file with <leader>ee and that one with <leader>eE

EOF

touch ~/project/provision/vim-macros-custom

install_vim_package junegunn/fzf "cd ~/.vim/bundle/fzf && ./install --all; cd -"
install_vim_package junegunn/fzf.vim
__add_n_completion() {
  ALL_CMDS="n sh RsyncDelete node l o GitAdd GitRevertCode nn ll"; sed -i "s|nvim $ALL_CMDS |nvim |; s|nvim |nvim $ALL_CMDS |" "$1";
  DIR_CMDS='mkdir tree'; sed -i "s|pushd $DIR_CMDS |pushd |; s|pushd |pushd $DIR_CMDS |" "$1";
}
__add_n_completion "$HOME"/.vim/bundle/fzf/shell/completion.bash
__add_n_completion "$HOME"/.fzf/shell/completion.bash

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
# they must begin with <leader>zm (where <leader> == <Space>)
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

cat >> ~/.shell_aliases <<"EOF"
alias VimSnippetsModify='nvim ~/project/provision/create_vim_snippets.sh && provision.sh'
alias VimCustomSnippetsModify='nvim ~/project/provision/custom_create_vim_snippets.sh && provision.sh'
EOF

if [ -f ~/project/provision/create_vim_snippets.sh ]; then
  sh ~/project/provision/create_vim_snippets.sh
else
  echo "~/project/provision/create_vim_snippets.sh file missing"
fi

## vim-textobj START

install_vim_package glts/vim-textobj-comment
install_vim_package kana/vim-textobj-indent
install_vim_package kana/vim-textobj-user
install_vim_package wellle/targets.vim

# examples: https://github.com/kana/vim-textobj-user/wiki

cat >> ~/.vimrc <<"EOF"
" regular expressions that match numbers (order matters .. keep '\d' last!)
" note: \+ will be appended to the end of each
let s:regNums = [ '0b[01]', '0x\x', '\d' ]

function! s:inNumber()
	" select the next number on the line
	" this can handle the following three formats (so long as s:regNums is
	" defined as it should be above this function):
	"   1. binary  (eg: "0b1010", "0b0000", etc)
	"   2. hex     (eg: "0xffff", "0x0000", "0x10af", etc)
	"   3. decimal (eg: "0", "0000", "10", "01", etc)
	" NOTE: if there is no number on the rest of the line starting at the
	"       current cursor position, then visual selection mode is ended (if
	"       called via an omap) or nothing is selected (if called via xmap)

	" need magic for this to work properly
	let l:magic = &magic
	set magic

	let l:lineNr = line('.')

	" create regex pattern matching any binary, hex, decimal number
	let l:pat = join(s:regNums, '\+\|') . '\+'

	" move cursor to end of number
	if (!search(l:pat, 'ce', l:lineNr))
		" if it fails, there was not match on the line, so return prematurely
		return
	endif

	" start visually selecting from end of number
	normal! v

	" move cursor to beginning of number
	call search(l:pat, 'cb', l:lineNr)

	" restore magic
	let &magic = l:magic
endfunction

function! CurrentLineA()
  normal! 0
  let head_pos = getpos('.')
  normal! $
  let tail_pos = getpos('.')
  return ['v', head_pos, tail_pos]
endfunction

function! CurrentLineI()
  normal! ^
  let head_pos = getpos('.')
  normal! g_
  let tail_pos = getpos('.')
  let non_blank_char_exists_p = getline('.')[head_pos[2] - 1] !~# '\s'
  return
  \ non_blank_char_exists_p
  \ ? ['v', head_pos, tail_pos]
  \ : 0
endfunction

" Mappings:
xnoremap <silent> iN :<c-u>call <sid>inNumber()<cr>
onoremap <silent> iN :<c-u>call <sid>inNumber()<cr>
call textobj#user#plugin('line', {
\   '-': {
\     'select-a-function': 'CurrentLineA',
\     'select-a': 'al',
\     'select-i-function': 'CurrentLineI',
\     'select-i': 'il',
\   },
\ })
autocmd User targets#mappings#user call targets#mappings#extend({
    \ 'a': { 'argument': [{'o': '[({[]', 'c': '[]})]', 's': ','}] }
    \ })

" glts/vim-textobj-comment: ic , ac, iC
EOF

add_special_vim_map "showtabnumber" $':echo tabpagenr()<cr>' 'show tab number'

## vim-textobj END

if [ -f ~/project/.config/copilot ]; then
  install_vim_package github/copilot.vim # https://github.com/github/copilot.vim
  cat >> ~/.vim/colors.vim <<"EOF"
hi CopilotSuggestion guifg=#ff8700 ctermfg=208
EOF

  cat >> ~/.vim/lua/extra_beginning.lua <<"EOF"
vim.api.nvim_set_keymap("i", "<C-_>", "<Plug>(copilot-next)", {silent = true, nowait = true})
vim.api.nvim_set_keymap("i", "<C-\>", "<Plug>(copilot-previous)", {silent = true, nowait = true})
EOF

  # This is due to the screen not cleaned when dismissing a suggestion
  cat >> ~/.vimrc <<"EOF"
function! CustomDismiss() abort
  unlet! b:_copilot_suggestion b:_copilot_completion
  call copilot#Clear()
  redraw!
  echo "Dismissed"
  return ''
endfunction

imap <silent><script><nowait><expr> <C-]> CustomDismiss() . "\<C-]>"
nmap <silent><script><nowait><expr> <C-]> CustomDismiss() . "\<C-]>"
EOF
fi

# LOCAL: current branch, BASE: original file, REMOTE: file in opposite branch
cat >> ~/.gitconfig <<"EOF"
[merge]
  tool = vimdiff
[mergetool]
  prompt = true
  keepBackup = false
[mergetool "vimdiff"]
  cmd = "$EDITOR" -p $MERGED $LOCAL $BASE $REMOTE
EOF

cat >> ~/.vim/lua/extra_beginning.lua <<"EOF"
-- Undo tree
vim.api.nvim_set_keymap("n", "<leader>mm", ":UndotreeShow<cr><c-w><left>", { noremap = true })

-- vim-expand-region
vim.api.nvim_set_keymap("v", "v", "<Plug>(expand_region_expand)", {})
vim.api.nvim_set_keymap("v", "<c-v>", "<Plug>(expand_region_shrink)", {})

-- fzf maps
vim.api.nvim_set_keymap("n", "<leader>ja", ":Ag!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jb", ":Buffers!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jc", ":Commands!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jg", ":GFiles!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jh", ":History!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jj", ":BLines!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jl", ":Lines!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jm", ":Marks!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jM", ":Maps!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jt", ":Tags!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jw", ":Windows!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jf", ":Filetypes!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>je", ":AnsiEsc!<cr>", { noremap = true })

-- Vista
vim.g.vista_default_executive = 'coc'
vim.g.vista_sidebar_width = 100

-- limelight
vim.g.limelight_conceal_ctermfg = 'LightGray'
vim.g.limelight_bop = '^'
vim.g.limelight_eop = '$'
vim.api.nvim_set_keymap("n", "<leader>zl", ":Limelight!!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>zL", ":let g:limelight_paragraph_span = <left><right>", { noremap = true })

-- auto-pairs
vim.g.AutoPairsMultilineClose = 0

-- incsearch.vim
vim.api.nvim_set_keymap("n", "/", "<Plug>(incsearch-forward)", {})
vim.api.nvim_set_keymap("n", "?", "<Plug>(incsearch-backward)", {})
vim.api.nvim_set_keymap("n", "g/", "<Plug>(incsearch-stay)", {})

-- nerdcommenter
vim.g.NERDSpaceDelims = 1

-- vim fugitive
vim.cmd('set diffopt+=vertical')
vim.cmd('command Gb Git blame')

-- vim-json
vim.g.vim_json_syntax_conceal = 0

-- save file shortcuts
vim.api.nvim_set_keymap("n", "<leader>ks", ':silent exec "!mkdir -p <c-R>=expand("%:p:h")<cr>"<cr>:w<cr>:silent exec ":CtrlPClearAllCaches"<cr>', { noremap = true })

-- markdown
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0
vim.g.vim_markdown_conceal = 0
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_folding_disabled = 1
vim.cmd 'autocmd Filetype markdown set conceallevel=0'

-- format json
vim.cmd 'command! -range -nargs=0 -bar JsonTool <line1>,<line2>!python -m json.tool'
vim.api.nvim_set_keymap("n", "<leader>kz", ':JsonTool<cr>', { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>kz", ":'<,'>JsonTool<cr>", { noremap = true })

vim.g.peekaboo_window='vert bo new'
EOF

if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|vim.g.limelight_conceal_ctermfg =.*|vim.g.limelight_conceal_ctermfg = "DarkGray"|' ~/.vim/lua/extra_beginning.lua
fi

# vim-extra END
