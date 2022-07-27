#!/usr/bin/env bash

set -e

MOUNT_PATH=/mnt
NAME=cryptdevice
KEY_PATH=~/usbkey.lek.asc
BLOCK_DEVICE=/dev/disk/by-label/FOO

sudo umount "$MOUNT_PATH" || true
sudo cryptsetup close /dev/mapper/"$NAME" || true

gpg --no-symkey-cache -d "$KEY_PATH" | \
  sudo cryptsetup --key-file=- open "$BLOCK_DEVICE" "$NAME"

sudo mount /dev/mapper/"$NAME" "$MOUNT_PATH"
