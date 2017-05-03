# gui START

if [ ! -f ~/.check-files/gui ]; then
  echo "installing gui"
  sudo pacman -S --noconfirm xfce4 xfce4-goodies
  mkdir -p ~/.check-files && touch ~/.check-files/gui
fi
sudo bash -c 'echo "allowed_users=anybody" > /etc/X11/Xwrapper.config'
sudo bash -c 'echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config'
cat >> ~/.bash_aliases <<"EOF"
alias StartXFCE4='startxfce4&'
alias XFCE4SettingsEditor='xfce4-settings-editor'
SetupXFCE4() {
  xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 25
  xfconf-query -c xfce4-desktop -np '/desktop-icons/style' -t 'int' -s '0'
}
EOF

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
    font = Monospace 14
    foreground_color = "#ffffff"
    icon_bell = False
    palette = "#073642:#d25071:#bbdba5:#00b5ac:#268bd2:#d33682:#7cbcb7:#eee8d5:#002b36:#eb8395:#586e75:#8f9fa5:#839496:#6c71c4:#93a1a1:#fdf6e3"
    scrollbar_position = hidden
    show_titlebar = False
    use_system_font = False
EOF

install_pacman_package chromium
install_pacman_package gimp

sudo pacman -S --noconfirm ttf-freefont ttf-arphic-uming ttf-baekmuk # fonts for chromium

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
  echo 'exec i3' > ~/.xinitrc
  cat >> ~/.bash_aliases <<"EOF"
  I3Start() {
    setxkbmap -layout gb;
    /usr/bin/VBoxClient-all;
  }
  alias ModifyI3Conf='$EDITOR /project/provision/i3-config; cp /project/provision/i3-config ~/.config/i3/config'
  alias I3Reload='i3-msg reload'
  alias I3Poweroff='systemctl poweroff'
  alias I3Start='startx'
EOF
  mkdir -p ~/.config/i3
  check_file_exists /project/provision/i3-config
  cp_or_exit /project/provision/i3-config ~/.config/i3

# gui END

# gui-extras START

# eclim
  if [ ! -f ~/.check-files/eclim ]; then
    cd ~
    wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
    java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
    touch ~/.check-files/eclim
  fi

# gui-extras END
