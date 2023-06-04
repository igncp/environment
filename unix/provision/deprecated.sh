# deprecated START

## js.sh

cat >> ~/.shell_aliases <<"EOF"
# Fix coloring of mocha in some windows terminals
alias Mocha="./node_modules/.bin/mocha -c $@ > >(perl -pe 's/\x1b\[90m/\x1b[92m/g') 2> >(perl -pe 's/\x1b\[90m/\x1b[92m/g' 1>&2)"
EOF

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
  if [ -f ~/development/environment/project/.config/polybar-small ]; then
    sed -i 's|height =.*|height = 20pt|' ~/.config/polybar/config.ini
    sed -i '/font-0/s|size=.*;|size=14;|' ~/.config/polybar/config.ini
    sed -i 's|tray-offset-y =.*|tray-offset-y = -20pt|' ~/.config/polybar/config.ini
  fi
  if [ -f ~/.check-files/polybar-interface ]; then
    sed -i "s|interface =.*|interface = $(cat ~/.check-files/polybar-interface)|" ~/.config/polybar/config.ini
  else
    echo '[~/.check-files/polybar-interface]: Add the interface for polybar (use `ip a`), e.g. wlo1'
  fi
  install_system_package stalonetray # In Polybar the system tray is disabled due to rendering issues
  echo 'alias TrayIcons="stalonetray --dockapp-mode simple"' >> ~/.shell_aliases

# Arch: polybar
if [ -f ~/project/provision/polybar.ini ]; then
  echo 'sudo pacman -Syu ; yay -Syu --noconfirm ; echo "Finished"; sleep 100' > ~/.scripts/update_system_polybar.sh
  chmod +x ~/.scripts/update_system_polybar.sh
  cat > /tmp/polybar_updates.sh <<"EOF"
pacman -Sy > /dev/null
UPDATES="$(pacman -Sup | wc -l)"
if [ "$UPDATES" == "0" ]; then
  echo "🍹"
else
  echo "♻️ $UPDATES"
fi
EOF
  sudo bash -c 'cat /tmp/polybar_updates.sh > /home/igncp/.scripts/polybar_updates.sh' ; rm -rf /tmp/polybar_updates.sh
  echo 'alacritty -e /home/igncp/.scripts/update_system_polybar.sh' > ~/.scripts/polybar_updates_click.sh
fi

# deprecated END
