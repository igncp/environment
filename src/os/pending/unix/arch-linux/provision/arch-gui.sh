# @TODO
# arch-gui START

install_with_yay pa-applet-git pa-applet
install_system_package pulsemixer # TUI mixer (simple)
install_with_yay ncpamixer        # TUI mixer (live pavucontrol)
if [ ! -f ~/.check-files/pulseaudio ]; then
  sudo pacman -S --noconfirm pulseaudio-alsa
  sudo usermod -a -G lp "$USER"
  sudo gpasswd -a "$USER" audio

  touch ~/.check-files/pulseaudio
fi
cat >>~/.shell_aliases <<"EOF"
alias PAListSinks="pacmd list-sinks | grep name: | grep -o '<.*>' | sed  's|[<>]||g'"
alias PASetSink="pacmd set-default-sink"
EOF
echo 'killall pa-applet || true' >>~/.scripts/gui_daemons.sh
echo '/usr/bin/pa-applet &' >>~/.scripts/gui_daemons.sh

# backups with GUI (timeshift-gtk)
if [ -f ~/development/environment/project/.config/timeshift ]; then install_with_yay timeshift; fi

if [ -f ~/development/environment/project/.config/diffpdf ]; then install_with_yay diffpdf; fi

if [ -f ~/development/environment/project/.config/irssi ]; then
  # set colors off
  install_system_package irssi
  echo 'alias Irssi="irssi"' >>~/.shell_aliases
fi

install_with_yay lxqt-sudo-git lxqt-sudo # for rofi

if [ -f ~/development/environment/project/.config/figma ]; then install_with_yay figma-linux; fi

if [ -z "$ARM_ARCH" ]; then
  if [ -f ~/development/environment/project/.config/espanso ]; then
    install_with_yay espanso
    check_file_exists ~/project/provision/espanso.yml
    touch ~/project/provision/espansoCustom.yml
    mkdir -p ~/.config/espanso
    cat >/tmp/espanso_cp_config.sh <<"EOF"
set -e
cp ~/project/provision/espanso.yml ~/.config/espanso/default.yml
cat ~/project/provision/espansoCustom.yml >> ~/.config/espanso/default.yml
EOF
    sh /tmp/espanso_cp_config.sh
    if ! type modulo >/dev/null 2>&1; then
      cd /tmp
      rm -rf ~/modulo
      git clone https://aur.archlinux.org/modulo.git
      cd modulo
      makepkg -si --noconfirm
      cd /tmp
      rm -rf ~/modulo
    fi
    cat >>~/.shell_aliases <<"EOF"
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

if [ -f ~/.config/snap ]; then
  if ! type modulo >/dev/null 2>&1; then
    cd ~
    rm -rf snapd
    git clone https://aur.archlinux.org/snapd.git
    cd snapd
    makepkg -si
    cd ~
    rm -rf snapd
    sudo systemctl enable --now snapd.socket
  fi

  cat >>~/.shellrc <<"EOF"
export PATH="$PATH:/var/lib/snapd/snap/bin/"
EOF
  cat >>~/.shell_aliases <<"EOF"
alias SnapRemove='snap remove'
alias SnapList='snap list'
EOF
fi

if [ -f ~/development/environment/project/.config/safeeyes ]; then
  if [ ! -f ~/.check-files/safeeyes ]; then
    install_with_yay safeeyes
    sudo pacman -S --noconfirm xprintidle # Required by the idle plugin
    pip install croniter                  # Required by the stats plugin
    touch ~/.check-files/safeeyes
  fi
  sed -i '1i(sleep 2s && safeeyes -e) &' ~/.xinitrc
fi

install_with_yay inxi

if [ -f ~/development/environment/project/.config/autokey ]; then
  install_with_yay autokey autokey-run
  install_with_yay autokey-gtk
  sed -i 's|"date"|"date +%s"|' ~/.config/autokey/data/Sample\ Scripts/Insert\ Date.py
fi

if [ -f ~/project/provision/i3blocks.sh ]; then
  cat >/tmp/i3blocks_updates.sh <<"EOF"
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
  echo "sudo $HOME/.scripts/i3blocks_updates.sh" >~/.scripts/i3blocks_updates_sudo.sh
  chmod +x ~/.scripts/i3blocks_updates_sudo.sh
  cat >/tmp/i3blocks_updates.txt <<"EOF"

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
  cat >~/.config/autostart/apparmor-notify.desktop <<"EOF"
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

cat >~/.scripts/acpi_warning.sh <<"EOF"
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
echo "*/4 * * * * $HOME/.scripts/acpi_warning.sh" >>/var/spool/cron/$USER

if [ -f ~/development/environment/project/.config/remote ]; then
  install_system_package playerctl
  install_system_package xdotool
  install_system_package xssstate

  if [ -f ~/development/environment/project/.config/vlc_move_cursor ]; then
    cat >~/.scripts/vlc_move_cursor.sh <<"EOF"
if [ -n "$(ps aux | grep -v '\bgrep\b' | grep '\bvlc\b' || true)" ]; then
  sh -c '(($(DISPLAY=:0 xssstate -i) > 20000)) && DISPLAY=:0 xdotool mousemove 0 0 && sleep 0.2 && DISPLAY=:0 xdotool mousemove 10 10'
fi
EOF
    chmod +x ~/.scripts/vlc_move_cursor.sh
    echo "*/9 * * * * $HOME/.scripts/vlc_move_cursor.sh" >>/var/spool/cron/"$USER"
  fi
fi

if [ -f ~/development/environment/project/.config__/x11-vnc-server-lightdm ]; then
  if [ ! -f /etc/x11vnc.pass ]; then echo 'You have to setup `/etc/x11vnc.pass` to run ~/development/environment/project/.config___/x11-vnc-server-lightdm'; fi
  sudo mkdir /etc/systemd/system/x11vnc.service.d/
  cat >/tmp/custom.conf <<"EOF"
[Unit]
Description=VNC Server for X11
Requires=graphical.target
After=graphical.target

[Service]
ExecStart=/usr/local/bin/x11vnc-lightdm

[Install]
WantedBy=graphical.target
EOF
  sudo mv /tmp/custom.conf /etc/systemd/system/x11vnc.service.d/
  cat >/tmp/custom.conf <<"EOF"
#!/bin/bash
/usr/bin/x11vnc -rfbauth /etc/x11vnc.pass -forever -loop -display :0 -auth '/run/lightdm/root/:0'
EOF
  sudo mv /tmp/x11vnc-lightdm /usr/local/bin/
  sudo chmod +x /usr/local/bin/x11vnc-lightdm
fi

# arch-gui END
