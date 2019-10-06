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

install_pacman_package xclip

# https://linuxiswonderful.wordpress.com/2017/05/01/x-broken-as-drmsetmaster-failed/
cat > /tmp/Xwrapper.config <<"EOF"
allowed_users=console
needs_root_rights=yes
EOF
sudo mv /tmp/Xwrapper.config /etc/X11/Xwrapper.config

cat > /tmp/locale.conf <<"EOF"
LANG=en_US.UTF-8
EOF
sudo mv /tmp/locale.conf /etc/locale.conf

cat >> ~/.bash_aliases <<"EOF"
alias XClipCopy='xclip -selection clipboard' # usage: echo foo | XClipCopy
alias XClipPaste='xclip -selection clipboard -o'
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
    font = Monospace 12
    foreground_color = "#ffffff"
    icon_bell = False
    palette = "#073642:#d25071:#bbdba5:#00b5ac:#268bd2:#d33682:#7cbcb7:#eee8d5:#002b36:#eb8395:#586e75:#8f9fa5:#839496:#6c71c4:#93a1a1:#fdf6e3"
    scrollbar_position = hidden
    show_titlebar = False
    use_system_font = False
  [[ttyd]]
    custom_command = TTYD
    exit_action = hold
    login_shell = True
    use_custom_command = True
  [[system-info]]
    custom_command = /home/igncp/.system-info.sh
    exit_action = hold
    login_shell = True
    use_custom_command = True
EOF
  # sed -i 's|font = Monospace .*|font = Monospace 14|' ~/.config/terminator/config

install_pacman_package gimp

install_pacman_package chromium
cat >> ~/.bash_aliases <<"EOF"
# useful to disable CORS without extensions
alias ChromiumWithoutSecurity='chromium --user-data-dir="~/chrome-without-security" --disable-web-security & exit'
alias ChromiumIncognito='chromium -incognito & exit'
alias Chromium='chromium & exit'
EOF

if [ ! -f ~/.check-files/gui-fonts ]; then
  sudo pacman -S --noconfirm ttf-freefont ttf-arphic-uming ttf-baekmuk # fonts for chromium
  mkdir -p ~/.check-files; touch ~/.check-files/gui-fonts
fi

# i3
  # to start it: startx
  if ! type i3 > /dev/null 2>&1 ; then
    install_pacman_package i3-wm
    install_pacman_package dmenu
    install_pacman_package i3status
    install_pacman_package i3lock

    cat > ~/i3lock.service <<"EOF"
[Unit]
Description=Lock screen before suspend
Before=sleep.target

[Service]
User=igncp
Type=forking
Environment=DISPLAY=:0
ExecStart=/usr/bin/i3lock -c 000000

[Install]
WantedBy=sleep.target
EOF
    sudo mv ~/i3lock.service /etc/systemd/system/
    sudo systemctl enable i3lock.service
  fi

  # dpi will change the font size of the gui menus
  cat > ~/.xinitrc <<"EOF"
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
  alias I3Start='bash ~/init.sh && startx'
EOF
  mkdir -p ~/.config/i3
  touch ~/init.sh
  check_file_exists /project/provision/i3-config
  cp /project/provision/i3-config ~/.config/i3/config

  cat >> ~/.bashrc <<"EOF"
# To exit: mod+shift+e or I3LogOut
if [ ! -f /tmp/first-i3 ]; then
  touch /tmp/first-i3

  sh ~/init.sh && startx
fi
EOF

# notifications handler (notify-send)
if ! type dunst > /dev/null 2>&1 ; then
  echo "Installing Dunst"
  (cd ~ \
    && rm -rf dunst \
    && git clone https://github.com/dunst-project/dunst.git \
    && cd dunst \
    && make && sudo make install)
  (mkdir -p ~/.config/dunst \
    && cp ~/dunst/dunstrc ~/.config/dunst/ \
    && rm -rf ~/dunst)
fi

# gui-extras available

# gui END
