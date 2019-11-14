# gui-extras START

# alacritty
  install_pacman_package alacritty
  check_file_exists /project/provision/alacritty.yml
  mkdir -p ~/.config/alacritty
  cp /project/provision/i3-config ~/.config/alacritty/alacritty.yml
  cat >> ~/.bash_aliases <<"EOF"
alias Alacritty='LANG=en_hk alacritty & exit'
alias ModifyAlacritty='$EDITOR /project/provision/alacritty.yml;
    cp /project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml; echo "alacritty.yml copied"'
EOF

# eclim
  if [ ! -f ~/.check-files/eclim ]; then
    cd ~
    wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
    java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
    touch ~/.check-files/eclim
  fi

# vscode
  if ! type code > /dev/null 2>&1 ; then
    if [ -f /home/igncp/Downloads/vscode.tar.gz ]; then
      (cd /home/igncp/Downloads \
        && sudo rm -rf /usr/bin/code /opt/visual-studio-code /home/igncp/Downloads/VSCode-* \
        && tar xf vscode.tar.gz \
        && sudo mv VSCode-* /opt/visual-studio-code \
        && sudo ln -s /opt/visual-studio-code/bin/code /usr/bin/code \
        && rm -rf vscode.tar.gz)
    else
      echo "Not installing VS Code because the file '~/Downloads/vscode.tar.gz' is missing."
      echo "  https://code.visualstudio.com/#alt-downloads"
    fi
  fi

  mkdir -p /home/igncp/.config/Code/User
  cp /project/provision/vscode-settings.json /home/igncp/.config/Code/User/settings.json

# Automatic X server
  cat >> ~/.bashrc <<"EOF"
if ! xhost >& /dev/null && [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  exec startx
fi
EOF

# Keys handling (for host)
  # For Brightness: update intel_backlight with the correct card
  sudo chown igncp /sys/class/backlight/intel_backlight/brightness
  cat > /home/igncp/change_brightness.sh <<"EOF"
  echo $(("$(cat /sys/class/backlight/intel_backlight/brightness)" + "$1")) | tee /sys/class/backlight/intel_backlight/brightness
EOF
  install_pacman_package xbindkeys
  cat > ~/.xbindkeysrc <<"EOF"
# Docs
# - https://wiki.archlinux.org/index.php/Xbindkeys#Installation
# - https://wiki.archlinux.org/index.php/Backlight#xbacklight
# refresh:
# - stop (all) xbindkeys process(es)
# - run: xbindkeys
# get key name: xbindkeys --multikey
# generate default config: xbindkeys -d > ~/.xbindkeysrc

# specify a mouse button
"amixer set Master 10%-"
  XF86AudioLowerVolume

"amixer set Master 10%+"
  XF86AudioRaiseVolume

# https://unix.stackexchange.com/a/385116
"sh /home/igncp/change_brightness.sh 3000"
  XF86MonBrightnessUp

"sh /home/igncp/change_brightness.sh -3000"
  XF86MonBrightnessDown
EOF
  cat >> ~/.bashrc <<"EOF"
IS_XBINDKEYS_RUNNING="$(ps aux | grep xbindkeys | grep -v grep)"
if [ -z "$IS_XBINDKEYS_RUNNING" ]; then xbindkeys; fi
EOF

# libre office
  install_pacman_package libreoffice-still libreoffice

# skype
  install_from_aur skypeforlinux https://aur.archlinux.org/skypeforlinux-stable-bin.git

# slack
  install_from_aur slack https://aur.archlinux.org/slack-desktop.git

# dropbox
  # Once installed, run `dropbox` and a URL will be opened
  if ! type entr > /dev/null 2>&1 ; then
    # https://aur.archlinux.org/packages/dropbox/#pinned-676597
    gpg --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E
  fi
  install_from_aur dropbox https://aur.archlinux.org/dropbox.git

# japanese IME using uim
  if [ ! -f ~/.check-files/japanese ]; then
    sudo pacman -S --noconfirm adobe-source-han-sans-jp-fonts otf-ipafont
    sudo pacman -S --noconfirm uim anthy
    mkdir -p ~/.check-files && touch ~/.check-files/japanese
  fi
  cp ~/.xinitrc /tmp/.xinitrc
  cat > ~/.xinitrc <<"EOF"
uim-toolbar-gtk &
export GTK_IM_MODULE='uim'
export QT_IM_MODULE='uim'
uim-xim &
export XMODIFIERS='@im=uim'
EOF
  cat /tmp/.xinitrc >> ~/.xinitrc
  # Preferences: uim-pref-gtk
  # Toolbar: uim-toolbar-gtk &
  # Choose: Authu (UTF-8)
  # Switch key: Shift+Space
  # Can remove toolbar and still use

# vlc
  install_pacman_package vlc

# gui-extras END
