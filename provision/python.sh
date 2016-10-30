# python START

if ! type pip > /dev/null  ; then
  echo "installing python tools"

  sudo apt-get install -y python-pip
fi

GLOBAL_PIP_MODULES=(flake8 plotly grip)

for MODULE_NAME in "${GLOBAL_PIP_MODULES[@]}"; do
  if [ ! -d /usr/local/lib/python2.7/dist-packages/$MODULE_NAME ]; then
    echo "doing: sudo pip install $MODULE_NAME"
    sudo pip install $MODULE_NAME
  fi
done

cat >> ~/.bash_aliases <<"EOF"
Grip() { grip $@ 0.0.0.0:6419; }
EOF

install_vim_package nvie/vim-flake8

cat >> ~/.vimrc <<"EOF"

let g:flake8_show_quickfix=0 " don't show quickfix
EOF

# python END
