# gui START

if [ ! -f ~/.check-files/gui ]; then
  echo "installing gui"
  install_pacman_package xorg
  install_pacman_package xorg-xinit
  mkdir -p ~/.check-files && touch ~/.check-files/gui
fi

if [ -f ~/.i3/config ]; then
  sed -i -r 's|\$mod\+([0-9]+) |$mod+Control+\1 |' ~/.i3/config
fi

# terminator
  install_pacman_package terminator
  mkdir -p ~/.config/terminator
  cat > ~/.config/terminator/config <<"EOF"
[global_config]
  title_transmit_bg_color = "#82a7b2"
[keybindings]
  next_tab = None
  prev_tab = None
[plugins]
[profiles]
  [[default]]
    allow_bold = False
    antialias = False
    background_image = None
    copy_on_selection = True
    cursor_blink = False
    cursor_color = "#ff0068"
    cursor_color_fg = False
    font = Monospace 12
    foreground_color = "#ffffff"
    icon_bell = False
    palette = "#073642:#d25071:#bbdba5:#00b5ac:#268bd2:#d33682:#7cbcb7:#eee8d5:#002b36:#eb8395:#586e75:#8f9fa5:#839496:#6c71c4:#93a1a1:#fdf6e3"
    scrollbar_position = hidden
    show_titlebar = False
    use_system_font = False
EOF

install_pacman_package chromium
install_pacman_package gimp

if [ ! -f ~/.check-files/gui-fonts ]; then
  sudo pacman -S --noconfirm ttf-freefont ttf-arphic-uming ttf-baekmuk # fonts for chromium
  mkdir -p ~/.check-files; touch ~/.check-files/gui-fonts
fi

# i3
  # to start it: startx
  if ! type i3 > /dev/null 2>&1 ; then
    install_pacman_package i3-wm
    install_pacman_package dmenu
    install_pacman_package gvim
    install_pacman_package i3status
  fi
  # dpi will change the font size of the gui menus
  cat > ~/.xinitrc <<"EOF"
  xrandr --dpi 150
  exec i3
EOF
  cat >> ~/.bash_aliases <<"EOF"
  I3Setup() {
    /usr/bin/VBoxClient-all;
  }
  alias I3GBLayout='setxkbmap -layout gb'
  alias ModifyI3Conf='$EDITOR /project/provision/i3-config; cp /project/provision/i3-config ~/.config/i3/config; echo Copied I3 Config'
  alias I3Reload='i3-msg reload'
  alias I3LogOut='i3-msg exit'
  alias I3Poweroff='systemctl poweroff'
  alias I3Start='startx'
EOF
  mkdir -p ~/.config/i3
  check_file_exists /project/provision/i3-config
  cp /project/provision/i3-config ~/.config/i3

# gui END

# gui-extras START

# alacritty
  if ! type alacritty > /dev/null 2>&1 ; then
    rm -rf ~/alacritty-git
    git clone https://aur.archlinux.org/alacritty-git.git ~/alacritty-git
    cd ~/alacritty-git
    makepkg -s
    sudo pacman -U ./*.pkg.tar.xz
    cd ~; rm -rf ~/alacritty-git
  fi
  check_file_exists /project/provision/alacritty.yml
  cp /project/provision/i3-config ~/.config/alacritty/alacritty.yml
  cat >> ~/.bash_aliases <<"EOF"
  alias ModifyAlacritty='$EDITOR /project/provision/alacritty.yml;
    cp /project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml; echo Alacritty copied'
EOF

# eclim
  if [ ! -f ~/.check-files/eclim ]; then
    cd ~
    wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
    java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
    touch ~/.check-files/eclim
  fi

install_from_aur code  https://aur.archlinux.org/visual-studio-code.git

# gui-extras END
