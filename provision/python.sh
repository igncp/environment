# python START

if ! type pip > /dev/null 2>&1; then
  echo "installing python tools"

  sudo apt-get install -y python-pip
fi

install_pip_modules() {
  for MODULE_NAME in "$@"; do
  if [ ! -d /usr/local/lib/python2.7/dist-packages/$MODULE_NAME ]; then
    echo "doing: sudo pip install $MODULE_NAME"
    sudo pip install $MODULE_NAME
  fi
  done
}

install_pip_modules flake8 plotly grip

cat >> ~/.bash_aliases <<"EOF"
Grip() { grip $@ 0.0.0.0:6419; }
EOF

install_vim_package nvie/vim-flake8

cat >> ~/.vimrc <<"EOF"

let g:flake8_show_quickfix=0 " don't show quickfix
EOF

# python END
