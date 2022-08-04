# arch-gui START

# pulseaudio: better audio support, including devices
install_system_package pulseaudio
install_with_yay paman
install_system_package pavucontrol # for audio settings
install_with_yay pa-applet-git pa-applet
install_system_package pulsemixer # TUI mixer (simple)
install_with_yay ncpamixer # TUI mixer (live pavucontrol)
if [ ! -f ~/.check-files/pulseaudio ]; then
  sudo pacman -S --noconfirm pulseaudio-alsa
  sudo usermod -a -G lp igncp
  sudo gpasswd -a igncp audio

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
if [ -f ~/project/.config/timeshift ]; then install_with_yay timeshift; fi

if [ -f ~/project/.config/copyq ]; then
  # clipboard manager
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

if [ -f ~/project/.config/nvidia ]; then
  if [ "$(cat ~/project/.config/nvidia)" == "yes" ]; then
    install_system_package nvidia nvidia-smi
    install_system_package nvidia-settings
    if [ ! -f ~/.check-files/nvidia-installed ]; then
      sudo pacman -S --noconfirm nvidia-utils mesa
      touch ~/.check-files/nvidia-installed
    fi
    cat > ~/.scripts/nvidia-config.sh <<"EOF"
#!/usr/bin/env bash
if [ ! -f /home/igncp/.nvidia-settings-rc ]; then
  exit
fi
sed -i 's|Brightness=.*|Brightness=-0.710000|g' /home/igncp/.nvidia-settings-rc
sed -i 's|Contrast=.*|Contrast=-0.710000|g' /home/igncp/.nvidia-settings-rc
sed -i 's|Gamma=.*|Gamma=1.087667|g' /home/igncp/.nvidia-settings-rc
nvidia-settings --load-config-only
EOF
    if [ ! -f /home/igncp/.nvidia-settings-rc ]; then
      echo "/home/igncp/.nvidia-settings-rc doesn't exist. Run 'nvidia-settings' to generate it"
    fi
    sed -i '1isleep 5s && sh /home/igncp/.scripts/nvidia-config.sh' ~/.xinitrc
  fi
else
  echo "[~/project/.config/nvidia]: file is missing, add it with 'yes' or 'no' to install nvidia packages"
fi

if [ -f ~/project/.config/skype  ]; then install_with_yay skypeforlinux-stable-bin skypeforlinux; fi

if [ -f ~/project/.config/slack  ]; then install_with_yay slack-desktop slack; fi

if [ -f ~/project/.config/postman ]; then install_with_yay postman-bin postman; fi

if [ -f ~/project/.config/dropbox ]; then
  # Once installed, run `dropbox` and a URL will be opened
  if ! type dropbox > /dev/null 2>&1 ; then
    # https://aur.archlinux.org/packages/dropbox/#pinned-676597
    gpg --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E
    sudo pacman -Sy python-gpgme # https://wiki.archlinux.org/title/dropbox#Required_packages
  fi
  install_with_yay dropbox
  echo '/home/igncp/.dropbox-dist/dropboxd &' >> ~/.scripts/gui_daemons.sh
fi

# https://zoom.us/download?os=linux
# sudo pacman -U ./zoom_x86_64.pkg.tar.xz
if [ -f ~/project/.config/zoom ]; then install_with_yay zoom; fi

if [ -f ~/project/.config/mysql-workbench ]; then install_system_package mysql-workbench; fi

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

if [ -f ~/project/.config/irssi ]; then
  # set colors off
  install_system_package irssi
  echo 'alias Irssi="irssi"' >> ~/.shell_aliases
fi

install_with_yay lxqt-sudo-git lxqt-sudo # for rofi

if [ -f ~/project/.config/figma ]; then install_with_yay figma-linux; fi

if [ -z "$ARM_ARCH" ]; then
  if [ -f ~/project/.config/virtualbox-host ]; then
    if ! type virtualbox > /dev/null 2>&1 ; then
      install_system_package virtualbox-host-modules-arch
      install_system_package virtualbox
      sudo usermod -a -G vboxusers igncp
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

  if [ -f ~/project/.config/espanso ]; then
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

if [ -f ~/project/.config/safeeyes ]; then
  if [ ! -f ~/.check-files/safeeyes ]; then
    install_with_yay safeeyes
    sudo pacman -S --noconfirm xprintidle # Required by the idle plugin
    pip install croniter # Required by the stats plugin
    touch ~/.check-files/safeeyes
  fi
  sed -i '1i(sleep 2s && safeeyes -e) &' ~/.xinitrc
fi

if [ -f ~/project/.config/headless-xorg ]; then
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

if [ -f ~/project/.config/autokey ]; then
  install_with_yay autokey autokey-run
  install_with_yay autokey-gtk
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
  echo 'sudo /home/igncp/.scripts/i3blocks_updates.sh' > ~/.scripts/i3blocks_updates_sudo.sh
  chmod +x ~/.scripts/i3blocks_updates_sudo.sh
  cat > /tmp/i3blocks_updates.txt <<"EOF"

[updates]
command="/home/igncp/.scripts/i3blocks_updates_sudo.sh"
interval=30
EOF
  sed -i '/global config end/r /tmp/i3blocks_updates.txt' ~/.config/i3blocks/config
  rm -rf /tmp/i3blocks_updates.txt
  if [ -z "$(sudo cat /etc/sudoers | grep i3blocks_updates.sh)" ]; then
    sudo sh -c 'echo "igncp ALL=NOPASSWD:/home/igncp/.scripts/i3blocks_updates.sh" >> /etc/sudoers'
  fi
fi

install_with_yay hardinfo

# It is started automatically with the desktop entry in `~/.config/autostart`
install_with_yay arch-audit-gtk

if [ ! -f ~/project/.config/no-dex ]; then
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

if [ -f ~/project/.config/tlp ]; then
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
echo '*/4 * * * * /home/igncp/.scripts/acpi_warning.sh' >> /var/spool/cron/igncp

if [ -f ~/project/.config/no-idle-gui ]; then
  echo "*/5 * * * * sh -c 'DISPLAY=:0 /usr/bin/xscreensaver-command -deactivate'" >> /var/spool/cron/igncp
fi

# arch-gui END
