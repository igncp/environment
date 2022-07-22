# arch-beginning START

if [ ! -f ~/.check-files/basic-packages ]; then
  echo "installing basic packages"
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm bash-completion
  sudo pacman -S --noconfirm xscreensaver libxss # Required by dunst

  touch ~/.check-files/basic-packages
fi

install_system_package() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: sudo pacman -S --noconfirm $PACKAGE"
    sudo pacman -S --noconfirm "$PACKAGE"
  fi
}

install_from_aur() {
  CMD_CHECK="$1"; REPO="$2"
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    git clone "$REPO"
    cd ./*
    makepkg -si --noconfirm
    cd; rm -rf "$TMP_DIR"
  fi
}

install_with_yay() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: yay -S --noconfirm $PACKAGE"
    yay -S --noconfirm "$PACKAGE"
  fi
}

if ! type yay > /dev/null 2>&1 ; then
  sudo pacman -S --noconfirm base-devel # required by yay
fi

install_from_aur yay https://aur.archlinux.org/yay-git.git

cat >> ~/.shell_aliases <<"EOF"
TimeManualSet() {
  sudo systemctl stop systemd-timesyncd.service
  sudo timedatectl set-time "$1" # "yyyy-MM-DD HH:MM:SS"
}
alias TimeManualUnset='sudo systemctl restart systemd-timesyncd.service'
EOF

cat >> ~/.shell_aliases <<"EOF"
alias PacmanCacheCleanHard='sudo pacman -Scc'
alias PacmanCacheCleanLight='sudo pacman -Sc'
alias PacmanFindPackageOfFile='pacman -Qo'
alias PacmanListExplicitPackages='pacman -Qe'
alias PacmanListFilesOfPackage='pacman -Ql'
alias PacmanListInstalledPackages='sudo pacman -Qs'
alias PacmanListPackagesByDate="expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort"
alias PacmanListUpdates='sudo pacman -Sy ; pacman -Sup'
alias PacmanSearchPackage='pacman -F'
alias PacmanUpdateRepos='sudo pacman -Sy'

alias SystemClean='sudo pacman -Sc'
alias SystemUpgrade='sudo pacman -Syu && yay -Syu --noconfirm'
EOF

install_system_package expac

# network
  cat >> ~/.shell_aliases <<"EOF"
WifiConnect() {
  sudo wifi-menu
  sudo dhcpcd
}
EOF
  # To enable Wifi network
  # ls -lah /etc/netctl # find the profile name
  # sudo netctl enable PROFILE_NAME

# autocomplete for sudo
  cat >> ~/.bashrc <<"EOF"
complete -cf sudo
EOF

install_system_package cronie crontab
# crontab -e
# DISPLAY=:0.0 /usr/bin/notify-send "[cronjob] TITLE" "CONTENT" # to send notification

install_system_package arch-install-scripts genfstab
install_system_package base-devel make
install_system_package nmap
install_system_package lftp

if ! type pkgfile > /dev/null 2>&1 ; then
  sudo pacman -S --noconfirm pkgfile
  sudo pkgfile -u
fi
echo 'source /usr/share/doc/pkgfile/command-not-found.bash' >> ~/.bashrc
echo 'source /usr/share/doc/pkgfile/command-not-found.zsh' >> ~/.zshrc

if ! type zramd > /dev/null 2>&1 ; then
  install_with_yay zramd
  sudo systemctl enable --now zramd
fi

cat >> ~/.shell_aliases <<"EOF"
alias GPGPinentryList='pacman -Ql pinentry | grep /usr/bin/'
EOF

# https://wiki.archlinux.org/title/Google_Authenticator
if [ -f ~/project/.config/gauth-pam ]; then
  install_system_package libpam-google-authenticator google-authenticator
fi

# Benchmarking
install_with_yay sysbench

install_system_package qrencode
cat >> ~/.shell_aliases <<"EOF"
alias QRTerminal='qrencode -t UTF8'
EOF

install_system_package usbutils lsusb

# Wiki: https://wiki.archlinux.org/title/USBGuard
# Rules https://github.com/USBGuard/usbguard/blob/master/doc/man/usbguard-rules.conf.5.adoc
install_system_package usbguard
cat >> ~/.shell_aliases <<"EOF"
alias USBGuardInit() {
  sudo sed -i 's|IPCAllowedUsers=root|IPCAllowedUsers=root igncp|' /etc/usbguard/usbguard-daemon.conf
  sudo bash -c 'usbguard generate-policy > /etc/usbguard/rules.conf'
  sudo systemctl enable --now usbguard
}
alias USBGuardBlocked='usbguard list-devices --blocked'
alias USBGuardAllowPermanently='usbguard allow-device -p'
EOF

# arch-beginning END
