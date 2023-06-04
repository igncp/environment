# ubuntu-gui START

# black screen after boot
# - On booting, press `Esc` to enter the GRUB screen
# - Press `e` on the `Ubuntu` line to enter the Edit Mode
# - Change `ro quiet splash` by `nomodeset quiet splash`
if [ ! -f ~/.check-files/lightdm ] ; then
  sudo apt-get install -y lightdm
  mkdir -p ~/.check-files && touch ~/.check-files/lightdm
  dkpg-reconfigure lightdm
fi

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

if [ ! -f ~/.check-files/adobe-font ]; then
  sudo apt-get install -y fonts-noto
  mkdir -p /tmp/adodefont
  cd /tmp/adodefont
  wget -q --show-progress -O source-code-pro.zip https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip
  unzip -q source-code-pro.zip -d source-code-pro
  fontpath="${XDG_DATA_HOME:-$HOME/.local/share}"/fonts
  mkdir -p $fontpath
  cp -v source-code-pro/*/OTF/*.otf $fontpath
  fc-cache -f
  rm -rf source-code-pro{,.zip}
  touch ~/.check-files/adobe-font
fi

echo "/usr/lib/update-notifier/apt-check --human-readable | head -1 | awk '{print "'$1'";}'" > ~/.scripts/polybar_updates.sh
echo "lxqt-sudo update-manager" > ~/.scripts/polybar_updates_click.sh

# @TODO: Automate installing firefox (no snap): https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04

# ubuntu-gui END
