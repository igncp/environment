# gui-xfce START

install_system_package xfce4 xfce4-about

cat >> ~/.shell_aliases <<"EOF"
alias StartX='startxfce4'
EOF

if [ ! -f ~/.check-files/xfce-setup ]; then
  install_system_package xfce4-systemload-plugin

  touch ~/.check-files/xfce-setup
fi

# gui-xfce END
