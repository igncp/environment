# brightscript START

install_vim_package chooh/brightscript.vim

cat >> ~/.vimrc <<"EOF"

let g:NERDCustomDelimiters = { 'brs': { 'left': "'",'right': ''  }  }
au BufRead,BufNewFile *.brs set filetype=brs
au FileType brs set tabstop=4
au FileType brs set shiftwidth=4
au FileType brs set softtabstop=4
EOF

# brightscript END
