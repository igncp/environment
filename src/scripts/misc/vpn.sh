#!/usr/bin/env bash

set -e

cd ~/vpn

sudo chown -R "$USER" ~/vpn

if [ ! -f ./pass.txt ]; then
  echo "Please create a file named pass.txt with your VPN credentials"
  exit 1
fi

UPDATE_SCRIPT="$(find /nix -name update-resolv-conf | head -n 1)"
USED_PROFILE=${USED_PROFILE:-$(find . -name '*.ovpn' | sort -V | head -n 1)}

sed -i 's|^auth-user-pass.*$|auth-user-pass pass.txt|' \
  "$USED_PROFILE"

sudo --preserve-env=PATH env openvpn \
  --config "$USED_PROFILE" \
  --script-security 2 \
  --up "$UPDATE_SCRIPT" \
  --down "$UPDATE_SCRIPT"
