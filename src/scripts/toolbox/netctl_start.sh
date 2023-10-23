#!/usr/bin/env bash

sudo echo '' > /dev/null # to enable sudo

NET_NAME=$(sudo netctl list |
  fzf --height 100% --border -m --ansi --header 'sudo netctl start')

[[ -z "$NET_NAME" ]] && exit 0

INTERFACE="$(ip a | grep wl | awk '{ print $2 }' | grep -o '[a-z0-9]*')"
CMD=''

if [ -n "$INTERFACE" ]; then
  CMD="sudo ip link set $INTERFACE down; "
fi

echo "$CMD sudo netctl start $NET_NAME"
