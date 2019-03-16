# gui START

if ! type startx > /dev/null 2>&1 ; then
  sudo apt-get install -y i3 xinit
fi

# terminator
  if ! type terminator > /dev/null 2>&1 ; then
    sudo apt-get install -y terminator
  fi
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
    font = Monospace 18
    foreground_color = "#ffffff"
    icon_bell = False
    palette = "#073642:#d25071:#bbdba5:#00b5ac:#268bd2:#d33682:#7cbcb7:#eee8d5:#002b36:#eb8395:#586e75:#8f9fa5:#839496:#6c71c4:#93a1a1:#fdf6e3"
    scrollbar_position = hidden
    show_titlebar = False
    use_system_font = False
EOF

install_ubuntu_package chromium-browser chromium-browser

# gui END
