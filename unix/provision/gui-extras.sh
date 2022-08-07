# gui-extras START

# terminator
  install_system_package terminator
  mkdir -p ~/.config/terminator
  cat > ~/.config/terminator/config <<"EOF"
[global_config]
[keybindings]
  new_tab = None
  cycle_next = None
  cycle_prev = None
  go_next = None
  go_prev = None
  go_up = None
  go_down = None
  go_left = None
  go_right = None
  rotate_cw = None
  rotate_ccw = None
  split_horiz = None
  split_vert = None
  close_term = None
  toggle_scrollbar = None
  search = None
  close_window = None
  resize_up = None
  resize_down = None
  resize_left = None
  resize_right = None
  move_tab_right = None
  move_tab_left = None
  toggle_zoom = None
  scaled_zoom = None
  next_tab = None
  prev_tab = None
  full_screen = None
  reset = None
  reset_clear = None
  hide_window = None
  group_all = None
  ungroup_all = None
  group_tab = None
  ungroup_tab = None
  new_window = None
  new_terminator = None
  insert_number = None
  insert_padded = None
  edit_window_title = None
  edit_tab_title = None
  edit_terminal_title = None
  layout_launcher = None
  help = None
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    background_color = "#ffffff"
    cursor_blink = False
    cursor_color = "#ffa7f4"
    cursor_color_fg = False
    font = Source Code Pro 18
    foreground_color = "#000000"
    icon_bell = False
    palette = "#000000:#8f5902:#005e04:#8f5902:#0000aa:#aa00aa:#004848:#eeeeec:#555555:#8f5902:#005e04:#c4a000:#5555ff:#5c3566:#204a87:#ffffff"
    scrollbar_position = hidden
    show_titlebar = False
    use_system_font = False
EOF
  # sed -i 's|font = .*|font = Monospace 14|' ~/.config/terminator/config

# Automatic X server (don't use if using lightdm)
  cat >> ~/.bashrc <<"EOF"
if ! xhost >& /dev/null && [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  exec startx
fi
EOF

# Check `unix/scripts/misc/vlc_playlist.sh`
install_system_package vlc

install_system_package android-file-transfer

install_system_package gnucash
if [ ! -f ~/.check-files/gnucash ]; then
  sudo pacman -S --noconfirm gnucash-docs

  touch ~/.check-files/gnucash
fi

# EBooks
  install_system_package calibre
  # [Arch]: After installing it may need:
  # [Arch]: sudo pacman -Syu ; pip install neovim

# Update display with xrandr
  # Custom resolution: https://askubuntu.com/a/377944
  mkdir -p ~/.displays
  cat > ~/.displays/laptop.sh <<"EOF"
#!/usr/bin/env bash

xrandr \
  --output DP-2 \
    --primary \
    --mode 1920x1080 \
    --pos 0x0 \
    -s 0 \
  --output HDMI-0 \
    --off

notify-send "Just laptop"
EOF
  cat > ~/.displays/same.sh <<"EOF"
#!/usr/bin/env bash

if [ -n "$(xrandr | grep HDMI | grep disconnected)" ]; then
  sh ~/.displays/laptop.sh
else
  xrandr \
    --output DP-2 \
      --primary \
      --mode 1920x1080 \
      --pos 0x0 \
      -s 0 \
      --rotate normal \
    --output HDMI-0 \
      --mode 1920x1080 \
      --pos 0x0 \
      -s 0 \
      --rotate normal
  notify-send "HDMI same"
fi
EOF
  cat > ~/.displays/right.sh <<"EOF"
#!/usr/bin/env bash

if [ -n "$(xrandr | grep HDMI | grep disconnected)" ]; then
  sh ~/.displays/laptop.sh
else
  xrandr \
    --output HDMI-0 \
      --primary \
      -s 0 \
      --mode 1920x1080 \
      --pos 1920x0 \
      --rotate normal \
    --output DP-2 \
      -s 0 \
      --primary \
      --mode 1920x1080 \
      --pos 0x0 \
      --rotate normal
  notify-send "HDMI right"
fi
EOF
  chmod -R +x ~/.displays

install_system_package chromium
cat >> ~/.shell_aliases <<"EOF"
# useful to disable CORS without extensions
alias ChromiumWithoutSecurity='chromium --user-data-dir="~/chrome-without-security" --disable-web-security & exit'
alias ChromiumIncognito='chromium -incognito & exit'
alias Chromium='chromium & exit'
EOF

# https://github.com/kraanzu/termtyper
if ! type termtyper > /dev/null 2>&1 ; then
  pip install preferredsoundplayer
  python3 -m pip install git+https://github.com/kraanzu/termtyper.git
fi

# gui-extras END
