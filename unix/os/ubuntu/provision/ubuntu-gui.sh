# ubuntu-gui START

install_system_package build-essential make

cat >> ~/.shell_aliases <<"EOF"
alias WifiConnect='nmtui'
EOF

# black screen after boot
# - On booting, press `Esc` to enter the GRUB screen
# - Press `e` on the `Ubuntu` line to enter the Edit Mode
# - Change `ro quiet splash` by `nomodeset quiet splash`
if [ ! -f ~/.check-files/lightdm ] ; then
  sudo apt-get install -y lightdm
  mkdir -p ~/.check-files && touch ~/.check-files/lightdm
  dkpg-reconfigure lightdm
fi

if [ -f ~/project/.config/dropbox ]; then
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
  mkdir -p ~/.config/systemd/user/
  cat > ~/.config/systemd/user/dropbox.service <<"EOF"
[Unit]
Description=Dropbox Service

[Service]
ExecStart=/home/igncp/.dropbox-dist/dropboxd
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF
  if [ ! -f /home/igncp/.config/systemd/user/default.target.wants/dropbox.service ]; then
    systemctl --user daemon-reload
    systemctl enable --now --user dropbox
  fi
fi

# Alacritty tweaks
  cat > /home/igncp/alacritty_ubuntu.sh <<"EOF"
LIBGL_ALWAYS_SOFTWARE=1 alacritty
EOF
  chmod +x /home/igncp/alacritty_ubuntu.sh
  if [ -f ~/.config/i3/config ]; then
    sed -i 's|exec alacritty|exec /home/igncp/alacritty_ubuntu.sh|' ~/.config/i3/config
  fi
  sed -i 's|size: .*|size: 18|' ~/.config/alacritty/alacritty.yml

if [ ! -f ~/.check-files/adobe-font ]; then
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

# ubuntu-gui END
