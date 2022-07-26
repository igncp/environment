# gui-i3 START

# to start it: startx
if ! type i3 > /dev/null 2>&1 ; then
  if [ -f ~/project/.config/standard-i3 ]; then install_system_package i3; else install_system_package i3-gaps; fi
  install_system_package i3lock
  install_system_package i3blocks

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
  $EDITOR -p ~/project/provision/i3-config ~/project/provision/i3blocks.sh
  provision.sh
}
EOF
mkdir -p ~/.config/i3
touch ~/init.sh # this file is not overridden so it can be changed manually
check_file_exists ~/project/provision/i3-config
cp ~/project/provision/i3-config ~/.config/i3/config
if [ -f ~/project/.config/standard-i3 ]; then
  sed -i '/gaps/d' ~/.config/i3/config
fi
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|background #.*|background #333333|' ~/.config/i3/config
  sed -i 's|statusline #.*|statusline #ffffff|' ~/.config/i3/config
fi

sh ~/project/provision/i3blocks.sh

# picom: can be disabled due performance
  if [ ! -f ~/project/.config/without-picom ]; then
    install_system_package picom
    cp ~/project/provision/picom.conf ~/.config/picom.conf
    check_file_exists ~/project/provision/picom.conf
    echo 'exec --no-startup-id picom' >> ~/.config/i3/config # remove this line to disable if performance slow
    echo "alias PicomModify='$EDITOR ~/project/provision/picom.conf && cp ~/project/provision/picom.conf ~/.config/picom.conf'" >> ~/.shell_aliases
  fi

echo 'exec /home/igncp/wallpaper-update.sh' >> ~/.config/i3/config

# I3 needs terminal emulator (e.g. terminator from gui-common) and may require custom fonts (e.g. arch-gui)

if type dunst > /dev/null 2>&1 ; then
  add_desktop_common \
    'dunstctl set-paused true' 'disable_notifications' 'Disable Notifications'

  add_desktop_common \
    'dunstctl set-paused false; notify-send "Time"' 'enable_notifications' 'Enable Notifications'
fi

# These require `polkit`, which is a dependency for example for `lightdm`
if [ -f ~/project/.config/inside ]; then
  sed -i -r '/mod\+Shift\+o/ s|exec ".*"|exec "systemctl suspend"|' ~/.config/i3/config
else
  sed -i -r '/mod\+Shift\+o/ s|exec ".*"|exec "systemctl poweroff"|' ~/.config/i3/config
fi

# gui-i3 END
