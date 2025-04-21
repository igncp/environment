#!/usr/bin/env bash

set -e

provision_setup_nvim_base() {
  if [ ! -f ~/.check-files/neovim ] || [ ! -f ~/.vimrc ]; then
    mkdir -p ~/.config ~/.vim
    touch ~/.vimrc
    rm -rf ~/.config/nvim
    rm -rf ~/.vim/init.vim
    ln -s ~/.vim ~/.config/nvim
    ln -s ~/.vimrc ~/.config/nvim/init.vim
    touch ~/.check-files/neovim

    # 如果沒有這個，打開文件時就會出錯
    if [ "$IS_DEBIAN" = "1" ]; then
      sudo apt install -y gcc
    elif [ "$IS_ARCH" = "1" ]; then
      sudo pacman -S --noconfirm gcc
    fi
  fi

  cat >>~/.vimrc <<"EOF"
if has('nvim')
  lua require("extra_beginning")
endif

" ctrlp
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_show_hidden = 1
  nnoremap <leader>p :CtrlP %:p:h<cr> " CtrlP in file's dir
  nnoremap <leader>P :CtrlPMRUFiles<cr>
  nnoremap <leader>kpk :CtrlPClearAllCaches<cr>
  nnoremap <leader>t :tabnew<cr>:CtrlP <left><right>
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob "" --hidden --glob "!.git"'
  nnoremap <leader>O :let g:CustomZPDir='<c-r>=expand(getcwd())<cr>'
  nnoremap <leader>o :CtrlP <c-r>=expand(g:CustomZPDir)<cr><cr>
  if exists("g:CustomZPDir") == 0
    let g:CustomZPDir=getcwd()
  endif

" lines in files
  nnoremap <leader>kr :-tabnew\|te ( F(){ find $1 -type f \| xargs wc -l \| sort -rn \|
  \ sed "s\|$1\|\|" \| sed "1i _" \| sed "1i $1" \| sed "1i _" \| sed '4d' \| less; }
  \ && F <c-R>=expand("%:p:h")<cr>/ )<left><left>

if has('nvim')
  " don't have to press the extra key when exiting the terminal (nvim)
  augroup terminal
    autocmd!
    autocmd TermClose * close
  augroup end
  autocmd TermOpen * startinsert
endif

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

nmap <silent> <c-a> :CopilotChatToggle<CR>
xnoremap <silent> <c-a> :<DEL><DEL><DEL><DEL><DEL>CopilotChatToggle<CR>
EOF

  cat >>~/.shellrc <<"EOF"
# This needs a check, as somtimes nvim is only available inside a nix shell
if type nvim > /dev/null 2>&1 ; then
    export EDITOR=nvim
fi

export TERM=xterm-256color
source "$HOME"/.shell_aliases # some aliases depend on $EDITOR
EOF

  cat >>~/.shell_aliases <<"EOF"
alias nn='nvim -n -u NONE -i NONE -N' # nvim without vimrc, plugins, syntax, etc
alias nb='nvim -n -u ~/.base-vimrc -i NONE -N' # nvim with base vimrc
alias XargsNvim='xargs nvim -p'
alias NvimRemoteXargs='xargs -I{} nvr -c "tab drop "{} -c "tabprevious"'
alias CheckVimSnippets='nvim ~/.local/share/nvim/lazy/vim-snippets/snippets'
# https://vi.stackexchange.com/a/277
NProfile() {
  nvim --startuptime /tmp/nvim-profile-log.txt "$@"
  cat /tmp/nvim-profile-log.txt  | grep '^[0-9]' | sort -r -k 2 | less
}
alias NSJson="nvim -c ':set syntax=json' -c ':set nofoldenable'"
alias NSYml="yq -S | nvim -c ':set syntax=json' -c ':set nofoldenable'"
EOF

  mkdir -p ~/.vim-snippets

  install_nvim_package junegunn/fzf "cd ~/.local/share/nvim/lazy/fzf && ./install --all; cd -"

  install_nvim_package "junegunn/fzf.vim"

  if [ ! -f ~/development/environment/project/.vim-custom.lua ]; then
    touch ~/development/environment/project/.vim-custom.lua
  fi

  bash ~/development/environment/src/scripts/misc/create_vim_snippets.sh

  cat >>~/.shell_aliases <<"EOF"
alias VimSnippetsModify='nvim ~/development/environment/src/scripts/misc/create_vim_snippets.sh && Provision'
alias VimCustomSnippetsModify='nvim ~/development/environment/project/custom_create_vim_snippets.sh && Provision'
EOF

  # LOCAL: current branch, BASE: original file, REMOTE: file in opposite branch
  cat >>~/.gitconfig <<"EOF"
[merge]
  tool = vimdiff
[mergetool]
  prompt = true
  keepBackup = false
[mergetool "vimdiff"]
  cmd = "$EDITOR" -p $MERGED $LOCAL $BASE $REMOTE
EOF

  if [ -f "$PROVISION_CONFIG"/copilot ]; then
    install_nvim_package github/copilot.vim
  fi

  if [ "$THEME" == "dark" ]; then
    sed -i "s|vim.g.limelight_conceal_ctermfg = 'LightGray'|vim.g.limelight_conceal_ctermfg = 'DarkGray'|" \
      ~/.vimrc
  fi
}
