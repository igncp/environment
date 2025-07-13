#!/usr/bin/env bash

set -euo pipefail

sudo chown -R "$USER" ~/vpn

if [ ! -f ~/vpn/pass.txt ]; then
  echo "請使用您的 VPN 憑證建立名為 pass.txt 的文件"
  exit 1
fi

UPDATE_SCRIPT="$(find /nix -name update-resolv-conf | head -n 1)"
USED_PROFILE=${USED_PROFILE:-$(find ~/vpn -name '*.ovpn' | sort -V | head -n 1)}

sed -i 's|^auth-user-pass.*$|auth-user-pass pass.txt|' \
  "$USED_PROFILE"

EXTRA_ARGS=()

if [ ! -f /etc/os-release ] || [ -z "$(grep -i 'nixos' /etc/os-release)" ]; then
  EXTRA_ARGS+=("--up" "$UPDATE_SCRIPT")
  EXTRA_ARGS+=("--down" "$UPDATE_SCRIPT")
fi

(cd ~/vpn && sudo --preserve-env=PATH env openvpn \
  --config "$USED_PROFILE" \
  --script-security 2 \
  "${EXTRA_ARGS[@]}")
