#!/usr/bin/env bash

# Copy this file into `mount_NAME_usb.sh`
# And replace the env vars

# The key file ideally should have root ownership. To copy it over the network can use:
# `ssh user@host -t "sudo cat ~/usbkey.lek.asc" | grep -v 'password for' | sudo tee $HOME/usbkey.lek.asc > /dev/null`
# Will have to enter the sudo password after connecting, even if there is no prompt

set -e

MOUNT_PATH=/mnt
NAME=cryptdevice
KEY_PATH=~/usbkey.lek.asc
BLOCK_DEVICE=/dev/disk/by-label/FOO

sudo umount "$MOUNT_PATH" || true
sudo cryptsetup close /dev/mapper/"$NAME" || true

sudo gpg -q --no-symkey-cache --pinentry-mode=loopback -d "$KEY_PATH" | \
  sudo cryptsetup --key-file=- open "$BLOCK_DEVICE" "$NAME"

sudo mount /dev/mapper/"$NAME" "$MOUNT_PATH"
