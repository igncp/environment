# gui-i3 START

# to start it: startx
if ! type i3 > /dev/null 2>&1 ; then
  if [ -f ~/project/.config/standard-i3 ]; then install_system_package i3; else install_system_package i3-gaps; fi
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
  $EDITOR ~/project/provision/i3-config
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

# polybar
  install_system_package polybar
  mkdir -p ~/.config/polybar
  check_file_exists ~/project/provision/polybar.ini
  cp ~/project/provision/polybar.ini ~/.config/polybar/config.ini
  sudo bash -c 'echo "echo 0" > /home/igncp/.scripts/polybar_updates.sh'
  if [ -z "$(sudo cat /etc/sudoers | grep 'polybar_updates')" ]; then
    sudo sed -i -e '$aigncp ALL=NOPASSWD:/home/igncp/.scripts/polybar_updates.sh' /etc/sudoers
  fi
  sudo chmod 500 /home/igncp/.scripts/polybar_updates.sh
  echo "" > ~/.scripts/polybar_updates_click.sh
  cat > ~/.config/polybar/launch.sh <<"EOF"
#!/usr/bin/env bash
polybar --config=/home/igncp/.config/polybar/config.ini main
EOF
  chmod +x ~/.config/polybar/launch.sh
  cat > ~/.config/systemd/user/polybar.service <<"EOF"
[Unit]
Description=Polybar

[Service]
ExecStart=/home/igncp/.config/polybar/launch.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
  if [ ! -f /home/igncp/.config/systemd/user/default.target.wants/polybar.service ]; then
    systemctl --user daemon-reload ; systemctl --user enable --now polybar
  fi
  cat > ~/.config/polybar/task_polybar.sh <<"EOF"
#!/bin/bash

most_urgent_desc=`task rc.verbose: rc.report.next.columns:description rc.report.next.labels:1 limit:1 next`
most_urgent_id=`task rc.verbose: rc.report.next.columns:id rc.report.next.labels:1 limit:1 next`
echo "$most_urgent_id" > /tmp/tw_polybar_id
if [ -z "$most_urgent_desc" ]; then
  echo ""
else
  echo "$most_urgent_desc ✅"
fi
EOF
  cat >> ~/.shell_aliases <<"EOF"
PolybarConfigure() {
  $EDITOR ~/project/provision/polybar.ini
  provision.sh
}
alias PolybarRestart='killall polybar; nohup /home/igncp/.config/polybar/launch.sh >/dev/null 2>&1 &'
EOF
  if [ -f ~/project/.config/polybar-small ]; then
    sed -i 's|height =.*|height = 20pt|' ~/.config/polybar/config.ini
    sed -i 's|size=.*;|size=14;|' ~/.config/polybar/config.ini
    sed -i 's|tray-offset-y =.*|tray-offset-y = -20pt|' ~/.config/polybar/config.ini
  fi
  if [ -f ~/.check-files/polybar-interface ]; then
    sed -i "s|interface =.*|interface = $(cat ~/.check-files/polybar-interface)|" ~/.config/polybar/config.ini
  else
    echo '[~/.check-files/polybar-interface]: Add the interface for polybar (use `ip a`), e.g. wlo1'
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

# I3 needs terminal emulator (e.g. terminator from gui-common) and may require custom fonts (e.g. arch-gui)

if type dunst > /dev/null 2>&1 ; then
  add_desktop_common \
    'dunstctl set-paused true' 'disable_notifications' 'Disable Notifications'

  add_desktop_common \
    'dunstctl set-paused false; notify-send "Time"' 'enable_notifications' 'Enable Notifications'
fi

# gui-i3 END
