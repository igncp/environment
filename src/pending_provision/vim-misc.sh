# @TODO
# vim-misc START

install_vim_package easymotion/vim-easymotion # https://github.com/easymotion/vim-easymotion
install_vim_package justinmk/vim-sneak        # https://github.com/justinmk/vim-sneak
install_vim_package luochen1990/rainbow       # https://github.com/luochen1990/rainbow
install_vim_package majutsushi/tagbar         # https://github.com/majutsushi/tagbar
install_vim_package takac/vim-hardtime        # https://github.com/takac/vim-hardtime
install_vim_package tkhren/vim-fake           # https://github.com/tkhren/vim-fake
install_vim_package xolox/vim-misc            # https://github.com/xolox/vim-misc

# @TODO: Move
install_vim_package mattn/emmet-vim                 # <C-y>,
install_vim_package martinda/Jenkinsfile-vim-syntax # https://github.com/martinda/Jenkinsfile-vim-syntax

cat >>~/.vimrc <<"EOF"
" easymotion
  nmap , <Plug>(easymotion-overwin-f)

" tagbar
  nmap <leader>v :TagbarToggle<cr>
  let g:tagbar_type_make = {'kinds':['m:macros', 't:targets']}
  let g:tagbar_type_markdown = {'ctagstype':'markdown','kinds':['h:Heading_L1','i:Heading_L2','k:Heading_L3']}

" vim-sneak
  hi! link Sneak Search
EOF

# vim-misc END
