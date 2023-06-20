# ubuntu-gui START

if [ -f ~/development/environment/project/.config/dropbox ]; then
  if [ ! -d ~/.dropbox-dist ]; then
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    cd ~/.dropbox-dist
    # Found here: https://help.dropbox.com/installs-integrations/desktop/linux-commands
    wget https://www.dropbox.com/download?dl=packages/dropbox.py
    mv download* dropbox
    chmod +x dropbox
  fi
  cat >> ~/.shellrc <<"EOF"
export PATH="$PATH:/home/igncp/.dropbox-dist"
EOF
  cat > ~/.config/systemd/user/dropbox.service <<"EOF"
[Unit]
Description=Dropbox Service

[Service]
ExecStart=/home/igncp/.dropbox-dist/dropboxd
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
  if [ ! -f /home/igncp/.config/systemd/user/default.target.wants/dropbox.service ]; then
    systemctl --user daemon-reload ; systemctl enable --now --user dropbox
  fi
fi

# There were some issues with Alacritty in Ubuntu ARM over silicon chip
if [ -z "$ARM_ARCH" ]; then
# Alacritty tweaks
  if ! type alacritty > /dev/null 2>&1 ; then
    sudo add-apt-repository -y ppa:aslatter/ppa
    sudo apt-get update
    sudo apt-get install -y alacritty
  fi
  cat > /home/igncp/.scripts/alacritty_ubuntu.sh <<"EOF"
LIBGL_ALWAYS_SOFTWARE=1 alacritty
EOF
  chmod +x /home/igncp/.scripts/alacritty_ubuntu.sh
  if [ -f ~/.config/i3/config ]; then
    sed -i 's|exec alacritty|exec /home/igncp/.scripts/alacritty_ubuntu.sh|' ~/.config/i3/config
  fi
else
  install_system_package terminator
fi

echo "/usr/lib/update-notifier/apt-check --human-readable | head -1 | awk '{print "'$1'";}'" > ~/.scripts/polybar_updates.sh
echo "lxqt-sudo update-manager" > ~/.scripts/polybar_updates_click.sh

# ubuntu-gui END
