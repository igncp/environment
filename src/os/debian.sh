#!/usr/bin/env bash

set -euo pipefail

. src/os/debian/surface.sh

provision_setup_os_debian() {
  install_system_package_os sudo
  install_system_package_os zsh
  install_system_package_os ufw

  if [ -f /etc/os-release ]; then
    IS_BOOKWORM="$(cat /etc/os-release | grep bookworm && echo 1 || echo 0)"
  fi

  # 對於 `podman`
  if ! type newuidmap >/dev/null 2>&1; then
    install_system_package_os uidmap
  fi

  if [ "$IS_BOOKWORM" = "1" ]; then
    # https://backports.debian.org/Instructions/
    if [ ! -f /etc/apt/sources.list.d/backports.list ]; then
      sudo bash -c "echo 'deb http://deb.debian.org/debian bookworm-backports main' > /etc/apt/sources.list.d/backports.list"
      sudo apt update
    fi
  fi

  cat >>~/.shellrc <<"EOF"
export DEBIAN_FRONTEND=noninteractive
EOF

  cat >>~/.shell_aliases <<"EOF"
alias SystemListInstalled='apt list --installed'
alias SystemUpgrade='sudo apt-get update && sudo apt-get upgrade -y'

alias AptLog='tail -f /var/log/apt/term.log'
EOF

  if [ -d /etc/ssh ]; then
    if [ ! -f ~/.ssh/authorized_keys ]; then
      echo "請將您的公用 SSH 金鑰新增至 ~/.ssh/authorized_keys"
      exit 1
    fi

    if [ ! -f "$PROVISION_CONFIG/ssh-pass" ] &&
      [ -n "$(grep '#PasswordAuthentication' /etc/ssh/sshd_config)" ]; then
      sudo sed -i 's|#PasswordAuthentication.*|PasswordAuthentication no|' /etc/ssh/sshd_config
      sudo systemctl restart ssh || true
    fi
  fi

  if [ "$IS_UBUNTU" = "1" ]; then
    cat >>~/.shell_aliases <<"EOF"
alias UbuntuVersion='lsb_release -a'
alias UbuntuFindPackageByFile="dpkg-query -S" # e.g. UbuntuFindPackageByFile '/usr/bin/ag'
alias UbuntuInstallDrivers='sudo ubuntu-drivers install'

DebianUninstallUI() {
  sudo apt purge --yes task-desktop hyphen-en-us libglu1-mesa libreoffice-* libu2f-udev mythes-en-us x11-apps x11-session-utils xinit xorg xserver-* desktop-base task-german task-german-desktop totem gedit gedit-common gir1.2-* gnome-* gstreamer* sound-icons speech-dispatcher totem-common xserver-* xfonts-* xwayland gir1.2* gnome-* 
  sudo apt install --yes sudo
  sudo apt autoremove --purge --yes
}
EOF
  fi

  # This avoids displaying the restart-services popup on every install
  if [ -f /etc/needrestart/needrestart.conf ]; then
    sudo sed "s|#\$nrconf{restart}.*|\$nrconf{restart} = 'a';|" \
      -i /etc/needrestart/needrestart.conf
  fi

  if [ -z "$(sudo systemctl list-units | grep unattended-upgrades | grep running || true)" ]; then
    sudo apt install -y unattended-upgrades
    echo "啟用無人管理嘅升級: sudo dpkg-reconfigure unattended-upgrades"
  fi

  # This disables the * when typing a password
  if [ -f /etc/sudoers.d/0pwfeedback ]; then
    sudo mv /etc/sudoers.d/0pwfeedback /etc/sudoers.d/0pwfeedback.disabled
  fi

  # Cleanup of the initial installation
  sudo rm -rf /root/.check-files
  sudo rm -rf /root/environment
  sudo rm -rf /root/.cargo

  sudo rm -rf ~/.scripts/motd_update.sh
  cat >~/.scripts/motd_update.sh <<"EOF"
echo "###" > /etc/motd
echo "Message created in $HOME/.scripts/motd_update.sh" >> /etc/motd
echo "Hello!" >> /etc/motd
echo "###" >> /etc/motd
echo "" >> /etc/motd
EOF
  sudo chown root:root ~/.scripts/motd_update.sh

  provision_setup_os_debian_surface
}
