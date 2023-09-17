#!/usr/bin/env bash

set -e

provision_setup_os_debian() {
  cat >>~/.shellrc <<"EOF"
export DEBIAN_FRONTEND=noninteractive
EOF

  cat >>~/.shell_aliases <<"EOF"
alias SystemListInstalled='apt list --installed'
alias SystemUpgrade='sudo apt-get update && sudo apt-get upgrade -y'

alias AptLog='tail -f /var/log/apt/term.log'
alias UbuntuVersion='lsb_release -a'
alias UbuntuFindPackageByFile="dpkg-query -S" # e.g. UbuntuFindPackageByFile '/usr/bin/ag'
EOF

  install_system_package python3
  install_system_package python3-pip pip3

  if ! type pip3 >/dev/null 2>&1; then
    if [ -f /usr/bin/pip3 ]; then
      sudo cp /usr/bin/pip3 /usr/bin/pip
    fi
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
}
