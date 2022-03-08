# gui-i3 START

# to start it: startx
if ! type i3 > /dev/null 2>&1 ; then
  install_system_package i3-gaps
  install_system_package i3status
  install_system_package i3lock

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

echo 'sh ~/.keyboard-config.sh' >> ~/.xinitrc
if [ ! -f ~/project/.config/no-auto-i3 ]; then
  echo 'exec i3' >> ~/.xinitrc
fi

cat >> ~/.shell_aliases <<"EOF"
I3VMSetup() {
  /usr/bin/VBoxClient-all;
  # Run `xrandr` to see the available outputs and modes:
    # xrandr --output Virtual-1 --mode 1280x768
}
alias I3GBLayout='setxkbmap -layout gb'
alias I3Reload='i3-msg reload'
alias I3LogOut='i3-msg exit'
alias I3DetectAppClass="xprop | grep WM_CLASS"
alias I3DetectAppName="xprop | grep WM_NAME"
alias I3Poweroff='systemctl poweroff'
alias I3Start='startx'
I3Configure() {
  $EDITOR -p ~/project/provision/i3-config ~/project/provision/i3-status-config
  cp ~/project/provision/i3-config ~/.config/i3/config
  cp ~/project/provision/i3-status-config ~/.config/i3status/config
  echo Copied I3 configs
}
EOF
mkdir -p ~/.config/i3
touch ~/init.sh # this file is not overridden so it can be changed manually
check_file_exists ~/project/provision/i3-config
check_file_exists ~/project/provision/i3-status-config
mkdir -p ~/.config/i3 ~/.config/i3status
cp ~/project/provision/i3-config ~/.config/i3/config
cp ~/project/provision/i3-status-config ~/.config/i3status/config
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|background #.*|background #333333|' ~/.config/i3/config
  sed -i 's|statusline #.*|statusline #ffffff|' ~/.config/i3/config
fi

# picom: can be disabled due performance
  if [ ! -f ~/project/.config/without-picom ]; then
    install_system_package picom
    cp ~/project/provision/picom.conf ~/.config/picom.conf
    check_file_exists ~/project/provision/picom.conf
    echo 'exec --no-startup-id picom' >> ~/.config/i3/config # remove this line to disable if performance slow
    echo "alias PicomModify='$EDITOR ~/project/provision/picom.conf && cp ~/project/provision/picom.conf ~/.config/picom.conf'" >> ~/.shell_aliases
  fi

echo 'exec /home/igncp/wallpaper-update.sh' >> ~/.config/i3/config

mkdir -p ~/.rofi_scripts

add_desktop_common() {
  CMD="$1"; FILE_NAME="$2"; NAME="$3"
  echo "$CMD" > ~/.rofi_scripts/"$FILE_NAME".sh
  chmod +x ~/.rofi_scripts/"$FILE_NAME".sh
  printf "[Desktop Entry]\nName=$NAME\nExec=/home/igncp/.rofi_scripts/$FILE_NAME.sh\nType=Application" > /tmp/"$FILE_NAME".desktop
  sudo mv /tmp/"$FILE_NAME".desktop /usr/share/applications/
}
  # For example:
  # add_desktop_common \
    # '/usr/bin/xdg-open /foo/bar.odt' \
    # 'open_foo_bar' \
    # 'Open Foo Bar'
  # Other command: google-chrome-stable https://foo.com

# I3 needs terminal emulator (e.g. terminator from gui-common) and may require custom fonts (e.g. arch-gui)

install_system_package rofi

if type dunst > /dev/null 2>&1 ; then
  add_desktop_common \
    'dunstctl set-paused true' 'disable_notifications' 'Disable Notifications'

  add_desktop_common \
    'dunstctl set-paused false; notify-send "Time"' 'enable_notifications' 'Enable Notifications'
fi

add_desktop_common \
  '/home/igncp/wallpaper-update.sh' 'wallpaper-update' 'Wallpaper Update'

# gui-i3 END
