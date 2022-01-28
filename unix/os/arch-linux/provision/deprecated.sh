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
      # Disable all except: Anthy (UTF-8)
  # Toolbar: uim-toolbar-gtk &
  # Switch key: Shift+Space
  # Check I3 shortcuts for opening toolbar in systray
