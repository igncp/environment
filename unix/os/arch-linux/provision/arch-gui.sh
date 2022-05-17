# arch-gui START

# pulseaudio: better audio support, including devices
install_system_package pulseaudio
install_with_yay paman
install_system_package pavucontrol # for audio settings
install_with_yay pa-applet-git pa-applet
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
sed -i '1isleep 15s && pa-applet 2>&1 > /dev/null &' ~/.xinitrc
# to fix application without sound
# killall pulseaudio ; rm -r ~/.config/pulse/* ; rm -r ~/.pulse*

# bluetooth
# for dual boot:
    # - copy the key in /var/lib/bluetooth/MAC/DEVICE_MAC/info
    # - power off the device after pairing with the 1st OS, copy it in the 2nd,
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

# clipboard manager
install_system_package copyq
# https://copyq.readthedocs.io/en/latest/faq.html#how-to-omit-storing-text-copied-from-specific-windows-like-a-password-manager
  # Create two items, one for the password manager and one for Entry
  # Click: "Show Advance", then click "Advanced" tab and put text on "Window" input (instead of "Password")
  if [ ! -f "$HOME"/.check-files/copyq-passwords ]; then
    echo '[~/.check-files/copyq-passwords]: Add and test command to filter out copied passwords and remove this message'
  fi
  if [ ! -f "$HOME"/.check-files/copyq-shortcut ]; then
    echo '[~/.check-files/copyq-shortcut]: Add ctrl + shift + 1 as shortcut to display copyq menu and remove this message'
  fi
sed -i '1isleep 10s && copyq 2>&1 > /dev/null &' ~/.xinitrc
cat >> ~/.shell_aliases <<"EOF"
CopyQReadN() {
  for i in {0..$1}; do
    echo "$i"
    copyq read "$i"
    echo ""; echo ""
  done
}
EOF

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
  sed -i 's|font = .*$|font = Monospace 12|' ~/.config/dunst/dunstrc
  sed -i 's|geometry = .*$|geometry = "500x5-30+20"|' ~/.config/dunst/dunstrc
  sed -i '1isleep 5s && dunst &' ~/.xinitrc
fi

# Keys handling (for host)
# For Brightness: update intel_backlight with the correct card
if [ -f /sys/class/backlight/intel_backlight/brightness ]; then
  sudo chown igncp /sys/class/backlight/intel_backlight/brightness
fi
cat > /home/igncp/change_brightness.sh <<"EOF"
echo $(("$(cat /sys/class/backlight/intel_backlight/brightness)" + "$1")) | tee /sys/class/backlight/intel_backlight/brightness
EOF
chmod +x /home/igncp/change_brightness.sh
if [ ! -f ~/.check-files/brightness-sudo ]; then
  echo "[~/.check-files/brightness-sudo]: Use 'sudo EDITOR=vim visudo' to add 'igncp archlinux = (root) NOPASSWD: /home/igncp/change_brightness.sh'"
fi
install_system_package xbindkeys
cat > ~/.xbindkeysrc <<"EOF"
# Docs
# - https://wiki.archlinux.org/index.php/Xbindkeys#Installation
# - https://wiki.archlinux.org/index.php/Backlight#xbacklight
# refresh:
# - stop (all) xbindkeys process(es)
# - run: xbindkeys
# get key name: xbindkeys --multikey # don't use tmux and run `xbindkeys` first
# generate default config: xbindkeys -d > ~/.xbindkeysrc

# specify a mouse button
"amixer set Master 10%-"
  XF86AudioLowerVolume

"amixer set Master 10%+"
  XF86AudioRaiseVolume

# https://unix.stackexchange.com/a/385116
"sudo /home/igncp/change_brightness.sh 2000"
  XF86MonBrightnessUp

"sudo /home/igncp/change_brightness.sh -2000"
  XF86MonBrightnessDown

"amixer set Master 1+ toggle"
  XF86AudioMute
EOF
cat >> ~/.bashrc <<"EOF"
IS_XBINDKEYS_RUNNING="$(ps aux | grep xbindkeys | grep -v grep)"
if [ -n "$IS_XBINDKEYS_RUNNING" ]; then killall xbindkeys; fi
xbindkeys
EOF
echo 'alias XbindkeysMultikey="xbindkeys --multikey"' >> ~/.shell_aliases

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
  fi
  install_with_yay dropbox
  sed -i '1isleep 15s && dropbox 2>&1 > /dev/null &' ~/.xinitrc
fi

# https://zoom.us/download?os=linux
# sudo pacman -U ./zoom_x86_64.pkg.tar.xz
if [ -f ~/project/.config/zoom ]; then install_with_yay zoom; fi

if [ -f ~/project/.config/mysql-workbench ]; then install_system_package mysql-workbench; fi

# desktop magnifier: https://github.com/stuartlangridge/magnus
install_with_yay magnus

# acpi warning
  install_system_package acpi
  echo 'alias BatteryRemaningTime="acpi"' >> ~/.shell_aliases
  cat > ~/.battery-warning.sh <<"EOF"
#!/bin/bash

BATTINFO=`acpi -b`
if [[ `echo $BATTINFO | grep Discharging` && `echo $BATTINFO | cut -f 5 -d " "` < 00:30:00 ]] ; then
    DISPLAY=:0.0 /usr/bin/notify-send "[cronjob] low battery" "$BATTINFO"
fi
EOF
chmod +x ~/.battery-warning.sh
if [ ! -f "$HOME"/.check-files/battery-warning-cronie ]; then
  echo '[~/.check-files/battery-warning-cronie]: add this to cronie and remove message'
fi
# crontab -e
# */1 * * * * /home/igncp/.battery-warning.sh

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

# set colors off
install_system_package irssi
echo 'alias Irssi="irssi"' >> ~/.shell_aliases

install_with_yay lxqt-sudo-git lxqt-sudo # for rofi

if [ -f ~/project/.config/figma ]; then install_with_yay figma-linux; fi

if [ -z "$ARM_ARCH" ]; then
  if ! type virtualbox > /dev/null 2>&1 ; then
    install_system_package virtualbox-host-modules-arch
    install_system_package virtualbox
  fi

  if [ ! -f ~/.check-files/lightdm ]; then
    sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter

    sudo systemctl enable --now lightdm.service

    # sudo pacman -S --noconfirm accountsservice # to fix a journalctl error

    touch ~/.check-files/lightdm
  fi
  rm -rf ~/.xprofile
  ln -s ~/.xinitrc ~/.xprofile

  install_with_yay google-chrome google-chrome-stable

  install_with_yay espanso
  check_file_exists ~/project/provision/espanso.yml
  touch ~/project/provision/espansoCustom.yml
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

if [ -f ~/.config/snap ]; then
  if ! type modulo > /dev/null 2>&1 ; then
    cd ~; rm -rf snapd
    git clone https://aur.archlinux.org/snapd.git
    cd snapd
    makepkg -si
    cd ~; rm -rf snapd
    sudo systemctl enable --now snapd.socket
  fi

  cat >> ~/.shell_aliases <<"EOF"
alias SnapRemove='snap remove'
alias SnapList='snap list'
EOF
fi

if [ ! -f ~/.check-files/safeeyes ]; then
  install_with_yay safeeyes
  sudo pacman -S xprintidle # Required by the idle plugin
  pip install croniter # Required by the stats plugin
  touch ~/.check-files/safeeyes
fi
sed -i '1isleep 2s && safeeyes -e &' ~/.xinitrc

# arch-gui END
