# arch-beginning START

if [ ! -f ~/.check-files/basic-packages ]; then
  echo "installing basic packages"
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm bash-completion

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

alias PacmanFindPackageOfFile='pacman -Qo'
alias PacmanListExplicitPackages='pacman -Qe'
alias PacmanListFilesOfPackage='pacman -Ql'
alias PacmanListInstalledPackages='sudo pacman -Qs'
alias PacmanListPackagesByDate='expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort'
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

# It doesn't compile in Raspberry Pi
if [ -z "$ARM_ARCH" ]; then
  # Used by coc-tsserver for some of the refactors
  install_with_yay watchman
fi

# arch-beginning END
