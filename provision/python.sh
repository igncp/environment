# python START

install_apt_package python2
install_apt_package python2-pip pip2

install_pip_modules() {
  for MODULE_NAME in "$@"; do
  if [ ! -d /usr/lib/python2.7/site-packages/$MODULE_NAME ]; then
    echo "doing: sudo pip install $MODULE_NAME"
    sudo pip2 install $MODULE_NAME
  fi
  done
}

install_pip_modules flake8 plotly grip httpie

cat >> ~/.bash_aliases <<"EOF"
Grip() { grip $@ 0.0.0.0:6419; }
EOF

install_vim_package nvie/vim-flake8

cat >> ~/.vimrc <<"EOF"

let g:flake8_show_quickfix=0 " don't show quickfix
EOF

# tensorflow
  install_pip_modules numpy pbr funcsigs
  if ! type tensorboard > /dev/null 2>&1 ; then
    echo "installing tensorflow"
    sudo pip2 install --upgrade pip
    export TF_BINARY_URL=https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.11.0-cp27-none-linux_x86_64.whl
    sudo pip2 install --upgrade $TF_BINARY_URL
  fi

# python END
