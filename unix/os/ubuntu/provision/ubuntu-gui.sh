# ubuntu-gui START

install_system_package build-essential make

install_system_package update-manager

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

if ! type vncserver > /dev/null 2>&1 ; then
  sudo apt-get install -y tightvncserver
fi

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

echo "/usr/lib/update-notifier/apt-check --human-readable | head -1 | awk '{print "'$1'";}'" > ~/.scripts/polybar_updates.sh
echo "lxqt-sudo update-manager" > ~/.scripts/polybar_updates_click.sh

if [ -f ~/project/.config/headless-xorg ]; then
  if [ -n "$(sudo systemctl is-active lightdm | grep '\bactive\b' || true)" ]; then
    sudo systemctl disable --now lightdm
  fi
  if [ -n "$(groups | grep '\btty\b' || true)" ]; then sudo usermod -a -G tty igncp; fi
  if [ -n "$(groups | grep '\bvideo\b' || true)" ]; then sudo usermod -a -G video igncp; fi
  cat > /tmp/10-headless.conf <<"EOF"
Section "Monitor"
        Identifier "dummy_monitor"
        HorizSync 28.0-80.0
        VertRefresh 48.0-75.0
        Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
EndSection

Section "Device"
        Identifier "dummy_card"
        VideoRam 256000
        Driver "dummy"
EndSection

Section "Screen"
        Identifier "dummy_screen"
        Device "dummy_card"
        Monitor "dummy_monitor"
        SubSection "Display"
        EndSubSection
EndSection
EOF
  sudo mv /tmp/10-headless.conf /etc/X11/xorg.conf.d/
  cat > /tmp/Xwrapper.config <<"EOF"
allowed_users = anybody
needs_root_rights = yes
EOF
  sudo mv /tmp/Xwrapper.config  /etc/X11/
  echo 'alias HeadlessStart="startx"' >> ~/.shell_aliases
  echo 'alias HeadlessXRandr="DISPLAY=:0 xrandr --output DUMMY0 --mode 1920x1080"' >> ~/.shell_aliases
fi

# ubuntu-gui END
