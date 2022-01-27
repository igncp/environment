# python-extras START

# - depends on vim-extra provision

install_pip_modules flake8

install_vim_package nvie/vim-flake8

cat >> ~/.vimrc <<"EOF"
let g:flake8_show_quickfix=0 " don't show quickfix
EOF

# python-extras START
