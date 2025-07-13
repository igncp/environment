# @TODO
#!/usr/bin/env bash

# Needs to be run

# First of all run `pacman -Syu` to update the system or it can have issues with SSL
# Reboot the machine
# Resize if needed with `cfdisk` and `resize2fs /dev/vda2`
# Then install `pacman -S rsync vim`
# Update the ssh config to allow root ssh (temporarily)
# Copy the current repo into the machine (into `/root/development/environment`)
# `rsync -rhv --exclude project ./ root@192.x.x.x:/root/environment`
# After the installation is done, you may have to disable PAM in sshd_config to login with the user

set -euo pipefail

pacman -S --noconfirm base-devel

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
