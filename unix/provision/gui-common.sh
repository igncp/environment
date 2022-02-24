# gui-common START

# spanish, japanese, pinyin and jyutping IME using ibus-rime
mv ~/.xinitrc /tmp/.xinit_after
cat > ~/.xinitrc <<"EOF"
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export QT4_IM_MODULE=ibus
GTK_THEME=Menta ibus-daemon -drx
EOF
if [ ! -d /usr/share/themes/Menta ]; then
  install_system_package mate-themes
fi
cat /tmp/.xinit_after >> ~/.xinitrc ; rm /tmp/.xinit_after
if ! type rime_deployer > /dev/null 2>&1 ; then
  install_system_package ibus
  install_system_package ibus-rime
fi
if [ ! -f ~/.config/ibus/rime/default.yaml ]; then
  mkdir -p ~/misc ~/.config/ibus/rime
  rm -rf ~/misc/plum
  git clone https://github.com/rime/plum.git ~/misc/plum
  cd ~/misc/plum
  ./rime-install rime-cantonese
  ./rime-install gkovacs/rime-japanese
  cp /usr/share/rime-data/default.yaml ~/.config/ibus/rime/
fi
# On RIME, press F4 to switch
# On IBusSettings, add English and Chinese - RIME
if [ ! -f "$HOME"/.check-files/ibus-shortcut-log ]; then
  echo '[~/.check-files/ibus-shortcut-log]: In ibus settings, remove the default Super+Space shortcut to switch IM, replace it by Shift+F9'
fi
cat >> ~/.shell_aliases <<"EOF"
alias IBusDaemon='ibus-daemon -drx'
alias IBusSettings='IBUS_PREFIX= python2 /usr/share/ibus/setup/main.py'
EOF
check_file_exists ~/project/provision/rime-config.yaml
cp ~/project/provision/rime-config.yaml ~/.config/ibus/rime/default.yaml
cat >> ~/.shell_aliases <<"EOF"
RimeConfigure() {
  $EDITOR -p ~/project/provision/rime-config.yaml
  cp ~/project/provision/rime-config.yaml ~/.config/ibus/rime/default.yaml
  echo Copied Rime config file
}
EOF

install_system_package xclip
cat >> ~/.shell_aliases <<"EOF"
alias XClipCopy='xclip -selection clipboard' # usage: echo foo | XClipCopy
alias XClipPaste='xclip -selection clipboard -o'
EOF

# alacritty
  install_system_package alacritty
  check_file_exists ~/project/provision/alacritty.yml
  mkdir -p ~/.config/alacritty
  cp ~/project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml
  # alacritty has live reload of config, sometimes it is better to change directly first
  cat >> ~/.shell_aliases <<"EOF"
alias AlacrittyModify='$EDITOR ~/project/provision/alacritty.yml &&
    cp ~/project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml; echo "alacritty.yml copied"'
EOF

if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i "s|'light'|'dark'|" ~/.config/alacritty/alacritty.yml
  sed -i 's|background: .*|background: "#404040"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|blue: .*|blue: "#a6bcff"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|cyan: .*|cyan: "#a8f1ff"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|foreground: .*|foreground: "#ffffff"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|green: .*|green: "#bdffcd"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|magenta: .*|magenta: "#ffcff9"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|red: .*|red: "#ffc7d3"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|yellow: .*|yellow: "#feffc7"|' ~/.config/alacritty/alacritty.yml
fi

install_system_package gimp

install_system_package imagemagick import # for screenshots with import
install_system_package feh # image preview
install_system_package nautilus # drag-n-drop files
install_system_package obs-studio obs # for video recording
install_system_package libreoffice-fresh libreoffice
install_system_package peek # for gif generation
install_system_package flameshot # for annotations in images
install_system_package lxappearance # gnome themes
install_system_package arandr # xrandr frontend
install_system_package tigervnc vncsession # vnc client

# vnc server, uses 5900 port by default
if [ -f ~/.check-files/vnc-server ]; then install_system_package x11vnc; fi

if [ -f ~/.check-files/discord ]; then install_system_package discord; fi

# remember to put the theme inside `/boot` if encrypted disk
# needs root access to start
install_system_package grub-customizer

# gui-common END
