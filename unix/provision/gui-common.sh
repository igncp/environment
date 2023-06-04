# gui-common START

# This file is intended only for Linux

if [ "$PROVISION_OS" == 'LINUX' ]; then
  cat > /tmp/.xinitrc <<"EOF"
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export QT4_IM_MODULE=ibus
EOF
  cat ~/.xinitrc >> /tmp/.xinitrc
  mv /tmp/.xinitrc ~/.xinitrc
  echo 'GTK_THEME=Menta /usr/bin/ibus-daemon -rxd' >> ~/.scripts/gui_daemons.sh
  if [ ! -d /usr/share/themes/Menta ]; then
    install_system_package mate-themes
  fi
  if ! type rime_deployer > /dev/null 2>&1 ; then
    install_system_package ibus
    install_system_package ibus-rime
  fi
  if [ ! -f ~/.config/ibus/rime/default.yaml ]; then
    mkdir -p ~/misc ~/.config/ibus/rime
    rm -rf ~/misc/plum
    git clone https://github.com/rime/plum.git ~/misc/plum
    cd ~/misc/plum
    ./rime-install rime-cantonese
    ./rime-install gkovacs/rime-japanese
    cp /usr/share/rime-data/default.yaml ~/.config/ibus/rime/
  fi
  # On RIME, press F4 to switch
  # On IBusSettings, add English and Chinese - RIME
  if [ ! -f "$HOME"/.check-files/ibus-shortcut-log ]; then
    echo '[~/.check-files/ibus-shortcut-log]: In ibus settings, change the default Super+Space shortcut to switch IM to Alt+l (language)'
  fi
  cat >> ~/.shell_aliases <<"EOF"
alias IBusDaemon='ibus-daemon -drx'
alias IBusSettings='IBUS_PREFIX= python2 /usr/share/ibus/setup/main.py'
EOF
  check_file_exists ~/project/provision/rime-config.yaml
  cp ~/project/provision/rime-config.yaml ~/.config/ibus/rime/default.yaml
  cat >> ~/.shell_aliases <<"EOF"
RimeConfigure() {
  $EDITOR -p ~/project/provision/rime-config.yaml
  cp ~/project/provision/rime-config.yaml ~/.config/ibus/rime/default.yaml
  echo Copied Rime config file
}
EOF
fi

if [ -z "$ARM_ARCH" ]; then
# alacritty
  install_system_package alacritty
  check_file_exists ~/project/provision/alacritty.yml
  mkdir -p ~/.config/alacritty
  cp ~/project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml
  # alacritty has live reload of config, sometimes it is better to change directly first
  cat >> ~/.shell_aliases <<"EOF"
alias AlacrittyModify='$EDITOR ~/project/provision/alacritty.yml &&
    cp ~/project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml; echo "alacritty.yml copied"'
EOF

if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i "s|'light'|'dark'|" ~/.config/alacritty/alacritty.yml
  sed -i 's|background: .*|background: "#404040"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|blue: .*|blue: "#a6bcff"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|cyan: .*|cyan: "#a8f1ff"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|foreground: .*|foreground: "#ffffff"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|green: .*|green: "#bdffcd"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|magenta: .*|magenta: "#ffcff9"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|red: .*|red: "#ffc7d3"|' ~/.config/alacritty/alacritty.yml
  sed -i 's|yellow: .*|yellow: "#feffc7"|' ~/.config/alacritty/alacritty.yml
fi
fi

mkdir -p ~/.config/gtk-3.0/
echo '[Settings]' > ~/.config/gtk-3.0/settings.ini
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  cat >> ~/.config/gtk-3.0/settings.ini <<"EOF"
gtk-application-prefer-dark-theme = true
gtk-theme-name=BlackMATE
EOF
fi

install_system_package imagemagick import # for screenshots with import
install_system_package feh # image preview

if [ ! -f ~/development/environment/project/.config/common-gui-light ]; then
  install_system_package gimp
  install_system_package nautilus # drag-n-drop files
  install_system_package libreoffice-fresh libreoffice
  install_system_package peek # for gif generation
  install_system_package flameshot # for annotations in images
  install_system_package lxappearance # gnome themes
fi

if [ -f ~/development/environment/project/.config/obs-studio ]; then install_system_package obs-studio obs; fi # for video recording

if [ -f ~/development/environment/project/.config/discord ]; then install_system_package discord; fi

if [ -f ~/development/environment/project/.config/gedit ]; then install_system_package gedit; fi

install_system_package rofi
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

add_desktop_common \
  '/home/igncp/.scripts/wallpaper_update.sh' 'wallpaper-update' 'Wallpaper Update'

# Bluetooth headphones command and rofi script
cat > ~/.scripts/bluetooth_headphones_connect.sh <<"EOF"
#!/usr/bin/env bash
bluetoothctl power on; bluetoothctl connect "$(cat ~/development/environment/project/.config/bluetooth-headphones-mac.txt)"
EOF
cat > ~/.scripts/bluetooth_headphones_disconnect.sh <<"EOF"
#!/usr/bin/env bash
bluetoothctl disconnect "$(cat ~/development/environment/project/.config/bluetooth-headphones-mac.txt)"
EOF
cat >> ~/.shell_aliases <<"EOF"
alias BluetoothHeadphonesConnect="bash ~/.scripts/bluetooth_headphones_connect.sh"
alias BluetoothHeadphonesDisconnect="bash ~/.scripts/bluetooth_headphones_disconnect.sh"
alias AudioTest='arecord -f cd - | tee /tmp/output.wav | aplay -'
EOF
chmod +x ~/.scripts/bluetooth_headphones_connect.sh ~/.scripts/bluetooth_headphones_disconnect.sh
add_desktop_common \
  '/home/igncp/.scripts/bluetooth_headphones_connect.sh' 'bluetooth_headphones_connect' 'Bluetooth Headphones Connect'
add_desktop_common \
  '/home/igncp/.scripts/bluetooth_headphones_disconnect.sh' 'bluetooth_headphones_disconnect' 'Bluetooth Headphones Disconnect'

# GPU monitoring
cat >> ~/.shell_aliases <<"EOF"
alias GPUInfo='sudo lshw -C display -short'
alias GPUStat='gpustat -cp'
EOF
if [ -f ~/development/environment/project/.config/nvidia ]; then
  if [ "$(cat ~/development/environment/project/.config/nvidia)" == "yes" ]; then
    if ! type gpustat > /dev/null 2>&1 ; then
      pip install gpustat
    fi
    install_system_package nvtop
  fi
fi
install_system_package mesa-utils glxgears

cat >> ~/.shell_aliases <<"EOF"
BluetoothFixIntel() {
  # https://unix.stackexchange.com/a/707841
  sudo rmmod btusb ; sudo rmmod btintel
  sleep 2
  sudo modprobe btintel ; sudo modprobe btusb
}
EOF

if [ -f ~/development/environment/project/.config/copyq ]; then
  install_system_package copyq
  # https://copyq.readthedocs.io/en/latest/faq.html#how-to-omit-storing-text-copied-from-specific-windows-like-a-password-manager
    # Create two items, one for the password manager and one for Entry
    # Click: "Show Advance", then click "Advanced" tab and put text on "Window" input (instead of "Password")
    if [ ! -f "$HOME"/.check-files/copyq-passwords ]; then
      echo '[~/.check-files/copyq-passwords]: Add and test command to filter out copied passwords and remove this message'
    fi
  sed -i '1i(sleep 10s && copyq 2>&1 > /dev/null) &' ~/.xinitrc
  cat >> ~/.shell_aliases <<"EOF"
CopyQReadN() {
  for i in {0..$1}; do
    echo "$i"
    copyq read "$i"
    echo ""; echo ""
  done
}
EOF
fi

# gui-common END
