# arch-gui START

install_with_yay pa-applet-git pa-applet
install_system_package pulsemixer # TUI mixer (simple)
install_with_yay ncpamixer # TUI mixer (live pavucontrol)
if [ ! -f ~/.check-files/pulseaudio ]; then
  sudo pacman -S --noconfirm pulseaudio-alsa
  sudo usermod -a -G lp "$USER"
  sudo gpasswd -a "$USER" audio

  touch ~/.check-files/pulseaudio
fi
cat >> ~/.shell_aliases <<"EOF"
alias PAListSinks="pacmd list-sinks | grep name: | grep -o '<.*>' | sed  's|[<>]||g'"
alias PASetSink="pacmd set-default-sink"
EOF
echo 'killall pa-applet || true' >> ~/.scripts/gui_daemons.sh
echo '/usr/bin/pa-applet &' >> ~/.scripts/gui_daemons.sh

# bluetooth
# for dual boot:
    # - Copy the key in /var/lib/bluetooth/MAC/DEVICE_MAC/info
      # - If the other OS is Windows, use PSExec64 to extract it into a .reg
      #   file, then remove the commas and convert to upper case
      # https://wiki.archlinux.org/title/bluetooth#For_Windows
    # - Power off the device after pairing with the 1st OS, copy it in the 2nd,
    #   reboot (without reboot, it didn't work), and only then power on device
if [ ! -f ~/.check-files/bluetooth ]; then
  sudo pacman -S --noconfirm bluez-utils
  sudo pacman -S --noconfirm bluez
  sudo pacman -S --noconfirm pulseaudio-bluetooth
  sudo systemctl enable --now bluetooth.service

  touch ~/.check-files/bluetooth
fi

# backups with GUI (timeshift-gtk)
if [ -f ~/development/environment/project/.config/timeshift ]; then install_with_yay timeshift; fi

if [ -f ~/development/environment/project/.config/diffpdf ]; then install_with_yay diffpdf; fi

if [ -z "$ARM_ARCH" ]; then
  if ! type dunst > /dev/null 2>&1 ; then
    echo "Installing Dunst"
    (cd ~ \
      && rm -rf dunst \
      && git clone https://github.com/dunst-project/dunst.git \
      && cd dunst \
      && make && sudo make install)
    (mkdir -p ~/.config/dunst \
      && cp ~/dunst/dunstrc ~/.config/dunst/ \
      && rm -rf ~/dunst)
  fi
  sed -i 's| history =|#history =|' ~/.config/dunst/dunstrc
  sed -i 's|max_icon_size =.*|max_icon_size = 32|' ~/.config/dunst/dunstrc
  sed -i 's|font = .*$|font = Monospace 12|' ~/.config/dunst/dunstrc
  sed -i 's|geometry = .*$|geometry = "500x5-30+20"|' ~/.config/dunst/dunstrc
  sed -i '1i(sleep 5s && dunst) &' ~/.xinitrc
fi

if [ -f ~/development/environment/project/.config/nvidia ]; then
  if [ "$(cat ~/development/environment/project/.config/nvidia)" == "yes" ]; then
    install_system_package nvidia nvidia-smi
    install_system_package nvidia-settings
    if [ ! -f ~/.check-files/nvidia-installed ]; then
      sudo pacman -S --noconfirm nvidia-utils mesa
      touch ~/.check-files/nvidia-installed
    fi
    cat > ~/.scripts/nvidia-config.sh <<"EOF"
#!/usr/bin/env bash
if [ ! -f "$HOME"/.nvidia-settings-rc ]; then
  exit
fi
sed -i 's|Brightness=.*|Brightness=-0.710000|g' "$HOME"/.nvidia-settings-rc
sed -i 's|Contrast=.*|Contrast=-0.710000|g' "$HOME"/.nvidia-settings-rc
sed -i 's|Gamma=.*|Gamma=1.087667|g' "$HOME"/.nvidia-settings-rc
nvidia-settings --load-config-only
EOF
    if [ ! -f "$HOME"/.nvidia-settings-rc ]; then
      echo "$HOME/.nvidia-settings-rc doesn't exist. Run 'nvidia-settings' to generate it"
    fi
    sed -i "1isleep 5s && sh $HOME/.scripts/nvidia-config.sh" ~/.xinitrc
  fi
else
  echo "[~/development/environment/project/.config/nvidia]: file is missing, add it with 'yes' or 'no' to install nvidia packages"
fi

if [ -f ~/development/environment/project/.config/skype  ]; then install_with_yay skypeforlinux-stable-bin skypeforlinux; fi

if [ -f ~/development/environment/project/.config/slack  ]; then install_with_yay slack-desktop slack; fi

if [ -f ~/development/environment/project/.config/postman ]; then install_with_yay postman-bin postman; fi

if [ -f ~/development/environment/project/.config/dropbox ]; then
  # Once installed, run `dropbox` and a URL will be opened
  if ! type dropbox > /dev/null 2>&1 ; then
    # https://aur.archlinux.org/packages/dropbox/#pinned-676597
    gpg --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E
    sudo pacman -Sy python-gpgme # https://wiki.archlinux.org/title/dropbox#Required_packages
  fi
  install_with_yay dropbox
  echo "$HOME/.dropbox-dist/dropboxd &" >> ~/.scripts/gui_daemons.sh
fi

# https://zoom.us/download?os=linux
# sudo pacman -U ./zoom_x86_64.pkg.tar.xz
if [ -f ~/development/environment/project/.config/zoom ]; then install_with_yay zoom; fi

if [ -f ~/development/environment/project/.config/mysql-workbench ]; then
  install_system_package mysql-workbench
  install_system_package gnome-keyring
fi

# desktop magnifier: https://github.com/stuartlangridge/magnus
install_with_yay magnus

if [ ! -f ~/.check-files/arch-fonts ]; then
  sudo pacman -S --noconfirm \
    adobe-source-han-sans-jp-fonts \
    adobe-source-han-serif-jp-fonts \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-font-awesome \
    otf-ipafont
  touch ~/.check-files/arch-fonts
fi

install_with_yay pdfsam # PDF manipulation
install_with_yay variety-git variety # Wallpapers

if [ ! -f ~/.check-files/nerd-fonts ]; then
  # https://github.com/ryanoasis/vim-devicons
  install_with_yay nerd-fonts-source-code-pro

  touch ~/.check-files/nerd-fonts
fi

if [ -f ~/development/environment/project/.config/irssi ]; then
  # set colors off
  install_system_package irssi
  echo 'alias Irssi="irssi"' >> ~/.shell_aliases
fi

install_with_yay lxqt-sudo-git lxqt-sudo # for rofi

if [ -f ~/development/environment/project/.config/figma ]; then install_with_yay figma-linux; fi

if [ -z "$ARM_ARCH" ]; then
  if [ -f ~/development/environment/project/.config/virtualbox-host ]; then
    if ! type virtualbox > /dev/null 2>&1 ; then
      install_system_package virtualbox-host-modules-arch
      install_system_package virtualbox
      sudo usermod -a -G vboxusers "$USER"
    fi
  fi

  # Enable autologin: https://wiki.archlinux.org/title/LightDM#Enabling_autologin
  if [ ! -f ~/.check-files/lightdm ]; then
    sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter

    sudo systemctl enable --now lightdm.service

    # sudo pacman -S --noconfirm accountsservice # to fix a journalctl error

    touch ~/.check-files/lightdm
  fi
  rm -rf ~/.xprofile
  ln -s ~/.xinitrc ~/.xprofile

  install_with_yay google-chrome google-chrome-stable
  echo '' > ~/.config/chrome-flags.conf
  if [ "$ENVIRONMENT_THEME" == "dark" ]; then
    cat >> ~/.config/chrome-flags.conf <<"EOF"
--force-dark-mode
--enable-features=WebUIDarkMode
EOF
  fi

  if [ -f ~/development/environment/project/.config/espanso ]; then
    install_with_yay espanso
    check_file_exists ~/project/provision/espanso.yml
    touch ~/project/provision/espansoCustom.yml
    mkdir -p ~/.config/espanso
    cat > /tmp/espanso_cp_config.sh <<"EOF"
set -e
cp ~/project/provision/espanso.yml ~/.config/espanso/default.yml
cat ~/project/provision/espansoCustom.yml >> ~/.config/espanso/default.yml
EOF
    sh /tmp/espanso_cp_config.sh
    if ! type modulo > /dev/null 2>&1 ; then
      cd /tmp; rm -rf ~/modulo
      git clone https://aur.archlinux.org/modulo.git
      cd modulo
      makepkg -si --noconfirm
      cd /tmp; rm -rf ~/modulo
    fi
    cat >> ~/.shell_aliases <<"EOF"
alias EspansoDisable='killall espanso'
alias EspansoEnable='espanso daemon &'
EspansoConfigure() {
  $EDITOR -p ~/project/provision/espanso.yml ~/project/provision/espansoCustom.yml && \
  sh /tmp/espanso_cp_config.sh
  echo Copied espanso config
}
EOF
  fi
fi

if [ -n "$ARM_ARCH" ]; then
  install_with_yay chromium
fi

if [ -f ~/.config/snap ]; then
  if ! type modulo > /dev/null 2>&1 ; then
    cd ~; rm -rf snapd
    git clone https://aur.archlinux.org/snapd.git
    cd snapd
    makepkg -si
    cd ~; rm -rf snapd
    sudo systemctl enable --now snapd.socket
  fi

  cat >> ~/.shellrc <<"EOF"
export PATH="$PATH:/var/lib/snapd/snap/bin/"
EOF
  cat >> ~/.shell_aliases <<"EOF"
alias SnapRemove='snap remove'
alias SnapList='snap list'
EOF
fi

if [ -f ~/development/environment/project/.config/safeeyes ]; then
  if [ ! -f ~/.check-files/safeeyes ]; then
    install_with_yay safeeyes
    sudo pacman -S --noconfirm xprintidle # Required by the idle plugin
    pip install croniter # Required by the stats plugin
    touch ~/.check-files/safeeyes
  fi
  sed -i '1i(sleep 2s && safeeyes -e) &' ~/.xinitrc
fi

if [ -f ~/development/environment/project/.config/headless-xorg ]; then
  if [ ! -f ~/.check-files/xf86-video-dummy ]; then sudo pacman -S xf86-video-dummy; touch ~/.check-files/xf86-video-dummy; fi
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
EOF
  sudo mv /tmp/Xwrapper.config  /etc/X11/
  echo 'alias HeadlessStart="startx"' >> ~/.shell_aliases
  echo 'alias HeadlessXRandr="DISPLAY=:0 xrandr --output DUMMY0 --mode 1920x1080"' >> ~/.shell_aliases
fi

install_with_yay inxi

if [ -f ~/development/environment/project/.config/autokey ]; then
  install_with_yay autokey autokey-run
  install_with_yay autokey-gtk
  sed -i 's|"date"|"date +%s"|' ~/.config/autokey/data/Sample\ Scripts/Insert\ Date.py
fi

if [ -f ~/project/provision/i3blocks.sh ]; then
  cat > /tmp/i3blocks_updates.sh <<"EOF"
pacman -Sy > /dev/null
UPDATES="$(pacman -Sup | wc -l)"
if [ "$UPDATES" == "0" ]; then
  echo "🍹 |"
else
  echo "♻️ $UPDATES |"
fi
EOF
  sudo mv /tmp/i3blocks_updates.sh ~/.scripts/i3blocks_updates.sh
  # This script can run any sudo code, so just allow r and x for user
  sudo chmod 500 ~/.scripts/i3blocks_updates.sh
  echo "sudo $HOME/.scripts/i3blocks_updates.sh" > ~/.scripts/i3blocks_updates_sudo.sh
  chmod +x ~/.scripts/i3blocks_updates_sudo.sh
  cat > /tmp/i3blocks_updates.txt <<"EOF"

[updates]
command="$HOME/.scripts/i3blocks_updates_sudo.sh"
interval=30
EOF
  sed -i '/global config end/r /tmp/i3blocks_updates.txt' ~/.config/i3blocks/config
  rm -rf /tmp/i3blocks_updates.txt
  if [ -z "$(sudo cat /etc/sudoers | grep i3blocks_updates.sh)" ]; then
    sudo sh -c "echo '$USER ALL=NOPASSWD:$HOME/.scripts/i3blocks_updates.sh' >> /etc/sudoers"
  fi
fi

install_with_yay hardinfo

# It is started automatically with the desktop entry in `~/.config/autostart`
install_with_yay arch-audit-gtk

if [ ! -f ~/development/environment/project/.config/no-dex ]; then
  install_system_package dex
  sed -i '1i(sleep 5s && dex -a) &' ~/.xinitrc
fi
if [ ! -f ~/.check-files/apparmor-gui-config ]; then
  pip install notify2
  pip install psutil
  mkdir -p ~/.config/autostart/
  cat > ~/.config/autostart/apparmor-notify.desktop <<"EOF"
[Desktop Entry]
Type=Application
Name=AppArmor Notify
Comment=Receive on screen notifications of AppArmor denials
TryExec=aa-notify
Exec=aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log
StartupNotify=false
NoDisplay=true
EOF
  touch ~/.check-files/apparmor-gui-config
fi

if [ -f ~/development/environment/project/.config/tlp ]; then
  install_with_yay tlpui
fi

cat > ~/.scripts/acpi_warning.sh <<"EOF"
#!/bin/bash

BATTINFO=$(acpi -b)
IS_DISCHARGING=$(echo $BATTINFO | grep Discharging)

if [[ "$IS_DISCHARGING" && $(echo "$BATTINFO" | cut -f 5 -d " ") < 00:30:00 ]] ; then
  PRINTED=$(echo "$BATTINFO" | sed 's|Battery .: ||')
  XDG_RUNTIME_DIR=/run/user/$(id -u) \
    /usr/bin/notify-send -u critical "Low battery" "$PRINTED"
fi
EOF
chmod +x ~/.scripts/acpi_warning.sh
echo "*/4 * * * * $HOME/.scripts/acpi_warning.sh" >> /var/spool/cron/$USER

if [ -f ~/development/environment/project/.config/remote ]; then
  install_system_package playerctl
  install_system_package xdotool
  install_system_package xssstate

  if [ -f ~/development/environment/project/.config/vlc_move_cursor ]; then
    cat > ~/.scripts/vlc_move_cursor.sh <<"EOF"
if [ -n "$(ps aux | grep -v '\bgrep\b' | grep '\bvlc\b' || true)" ]; then
  sh -c '(($(DISPLAY=:0 xssstate -i) > 20000)) && DISPLAY=:0 xdotool mousemove 0 0 && sleep 0.2 && DISPLAY=:0 xdotool mousemove 10 10'
fi
EOF
    chmod +x ~/.scripts/vlc_move_cursor.sh
    echo "*/9 * * * * $HOME/.scripts/vlc_move_cursor.sh" >> /var/spool/cron/"$USER"
  fi
fi

if [ -f ~/development/environment/project/.config/x11-vnc-server-lightdm ]; then
  install_system_package x11vnc
  if [ ! -f /etc/x11vnc.pass ]; then echo 'You have to setup `/etc/x11vnc.pass` to run ~/development/environment/project/.config/x11-vnc-server-lightdm'; fi
  sudo mkdir /etc/systemd/system/x11vnc.service.d/
  cat > /tmp/custom.conf <<"EOF"
[Unit]
Description=VNC Server for X11
Requires=graphical.target
After=graphical.target

[Service]
ExecStart=
ExecStart=/usr/local/bin/x11vnc-lightdm

[Install]
WantedBy=graphical.target
EOF
  sudo mv /tmp/custom.conf /etc/systemd/system/x11vnc.service.d/
  cat > /tmp/custom.conf <<"EOF"
#!/bin/bash
/usr/bin/x11vnc -rfbauth /etc/x11vnc.pass -forever -loop -display :0 -auth '/run/lightdm/root/:0'
EOF
  sudo mv /tmp/x11vnc-lightdm /usr/local/bin/
  sudo chmod +x /usr/local/bin/x11vnc-lightdm
fi

install_system_package xsel

# arch-gui END
