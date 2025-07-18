# @TODO
#!/usr/bin/env bash

# Needs to be run as root or with sudo

set -euo pipefail

sudo apt-get update

if [ -f /etc/needrestart/needrestart.conf ]; then
  # This avoids displaying the restart-services popup on every install
  sudo sed "s|#\$nrconf{restart}.*|\$nrconf{restart} = 'a';|" -i /etc/needrestart/needrestart.conf
fi

sudo apt-get install -y build-essential
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
