#!/usr/bin/env bash

set -e

provision_setup_os_debian() {
  install_system_package_os sudo
  install_system_package_os ufw

  cat >>~/.shellrc <<"EOF"
export DEBIAN_FRONTEND=noninteractive
EOF

  cat >>~/.shell_aliases <<"EOF"
alias SystemListInstalled='apt list --installed'
alias SystemUpgrade='sudo apt-get update && sudo apt-get upgrade -y'

alias AptLog='tail -f /var/log/apt/term.log'
EOF

  if [ "$IS_UBUNTU" == "1" ]; then
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

  if [ ! -f ~/.check-files/debian-non-free ]; then
    if [ -z "$(cat /etc/apt/sources.list | grep -E 'non-free([^-]|$)' || true)" ]; then
      sudo apt install -y software-properties-common
      sudo apt-add-repository -y --component non-free
      sudo apt update
      touch ~/.check-files/debian-non-free
    fi
  fi
}
