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
install_system_package age # https://github.com/FiloSottile/age
install_system_package arch-audit # When using GUI, there is a GTK tray icon to check for CVEs

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
  # - `/etc/pam.d/sshd`: `auth required pam_google_authenticator.so`
  # - `/etc/ssh/sshd_config`: `KbdInteractiveAuthentication yes`
  # - `/etc/ssh/sshd_config`: `AuthenticationMethods keyboard-interactive:pam,publickey`
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
function USBGuardInit() {
  sudo sed -i 's|IPCAllowedUsers=root|IPCAllowedUsers=root igncp|' /etc/usbguard/usbguard-daemon.conf
  sudo bash -c 'usbguard generate-policy > /etc/usbguard/rules.conf'
  sudo systemctl enable --now usbguard
}
alias USBGuardBlocked='usbguard list-devices --blocked'
alias USBGuardAllowPermanently='usbguard allow-device -p'
EOF

install_system_package oath-toolkit oathtool

install_system_package apparmor apparmor_status
if [ ! -f ~/.check-files/apparmor-config ]; then
  sudo pacman -S --noconfirm audit
  sudo systemctl enable --now apparmor
  sudo groupadd -r audit || true
  sudo gpasswd -a igncp audit || true
  sudo sed -i 's|^log_group =.*|log_group = audit|' /etc/audit/auditd.conf
  sudo systemctl enable --now auditd
  touch ~/.check-files/apparmor-config
fi

# For example:
  # - `sudo iostat /dev/sda1 1` # Monitors IO (read/write speeds) every second
  # - `sudo iostat` # Stats for all devices
install_system_package sysstat iostat

# Power saving diagnostics
install_system_package powertop

if [ -f ~/project/.config/tlp ]; then
  install_system_package tlp
  install_system_package tlp-rdw

  if [ ! -f ~/.check-files/tlp ]; then
    sudo systemctl enable --now tlp
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket

    touch ~/.check-files/tlp
  fi
fi

install_system_package hwinfo

install_with_yay ananicy
if [ ! -f ~/.check-files/ananicy ]; then
  sudo sed -i 's|"type": "[^"]*"|"type": "Game"|' /etc/ananicy.d/00-default/node.rules
  sudo systemctl enable --now ananicy
  touch ~/.check-files/ananicy
fi

install_system_package i7z
install_system_package cpupower
install_with_yay cpupower-gui

if [ -f ~/project/.config/tailscale ]; then
  if [ ! -f ~/.check-files/tailscale ]; then
    install_system_package tailscale
    sudo systemctl enable --now tailscale
    touch ~/.check-files/tailscale
  fi
fi

# arch-beginning END
