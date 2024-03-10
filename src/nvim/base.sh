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
  fi

  install_nvim_package LnL7/vim-nix                    # https://github.com/LnL7/vim-nix
  install_nvim_package NvChad/nvim-colorizer.lua       # https://github.com/NvChad/nvim-colorizer.lua
  install_nvim_package andrewRadev/splitjoin.vim       # gS, gJ
  install_nvim_package bogado/file-line                # https://github.com/bogado/file-line
  install_nvim_package chentoast/marks.nvim            # https://github.com/chentoast/marks.nvim
  install_nvim_package ctrlpvim/ctrlp.vim              # https://github.com/ctrlpvim/ctrlp.vim
  install_nvim_package elzr/vim-json                   # https://github.com/elzr/vim-json
  install_nvim_package google/vim-searchindex          # https://github.com/google/vim-searchindex
  install_nvim_package haya14busa/incsearch.vim        # https://github.com/haya14busa/incsearch.vim
  install_nvim_package honza/vim-snippets              # https://github.com/honza/vim-snippets
  install_nvim_package iamcco/markdown-preview.nvim    # https://github.com/iamcco/markdown-preview.nvim
  install_nvim_package jiangmiao/auto-pairs            # https://github.com/jiangmiao/auto-pairs
  install_nvim_package jparise/vim-graphql             # https://github.com/jparise/vim-graphql
  install_nvim_package junegunn/limelight.vim          # https://github.com/junegunn/limelight.vim
  install_nvim_package junegunn/vim-peekaboo           # https://github.com/junegunn/vim-peekaboo
  install_nvim_package lbrayner/vim-rzip               # https://github.com/lbrayner/vim-rzip
  install_nvim_package lewis6991/gitsigns.nvim         # https://github.com/lewis6991/gitsigns.nvim
  install_nvim_package liuchengxu/vista.vim            # https://github.com/liuchengxu/vista.vim
  install_nvim_package mbbill/undotree                 # https://github.com/mbbill/undotree
  install_nvim_package mfussenegger/nvim-dap           # https://github.com/mfussenegger/nvim-dap
  install_nvim_package ntpeters/vim-better-whitespace  # https://github.com/ntpeters/vim-better-whitespace
  install_nvim_package nvim-treesitter/nvim-treesitter # https://github.com/nvim-treesitter/nvim-treesitter
  install_nvim_package plasticboy/vim-markdown         # https://github.com/plasticboy/vim-markdown
  install_nvim_package rcarriga/nvim-dap-ui            # https://github.com/rcarriga/nvim-dap-ui
  install_nvim_package rhysd/clever-f.vim              # https://github.com/rhysd/clever-f.vim
  install_nvim_package ryanoasis/vim-devicons          # if not supported, add in custom: rm -rf ~/.local/share/nvim/lazy/vim-devicons/*
  install_nvim_package scrooloose/nerdcommenter        # https://github.com/scrooloose/nerdcommenter
  install_nvim_package sindrets/diffview.nvim          # https://github.com/sindrets/diffview.nvim
  install_nvim_package tommcdo/vim-exchange            # https://github.com/tommcdo/vim-exchange
  install_nvim_package tpope/vim-eunuch                # https://github.com/tpope/vim-eunuch
  install_nvim_package tpope/vim-fugitive              # https://github.com/tpope/vim-fugitive
  install_nvim_package tpope/vim-repeat                # https://github.com/tpope/vim-repeat
  install_nvim_package tpope/vim-surround              # https://github.com/tpope/vim-surround
  install_nvim_package vim-scripts/AnsiEsc.vim         # https://github.com/vim-scripts/AnsiEsc.vim

  # Themes
  install_nvim_package morhetz/gruvbox # https://github.com/morhetz/gruvbox

  install_nvim_package cocopon/iceberg.vim # https://github.com/cocopon/iceberg.vim
  install_nvim_package dracula/vim         # https://github.com/cocopon/iceberg.vim

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

  __add_n_completion() {
    ALL_CMDS="n sh RsyncDelete node l o GitAdd GitRevertCode nn ll"
    sed -i "s|nvim $ALL_CMDS |nvim |; s|nvim |nvim $ALL_CMDS |" "$1"
    DIR_CMDS='mkdir tree'
    sed -i "s|pushd $DIR_CMDS |pushd |; s|pushd |pushd $DIR_CMDS |" "$1"
  }
  __add_n_completion "$HOME"/.local/share/nvim/lazy/fzf/shell/completion.bash || true
  __add_n_completion "$HOME"/.fzf/shell/completion.bash || true

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
