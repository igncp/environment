#!/usr/bin/env bash

# Copy this file into `~/project/scripts/custom/mount_NAME_usb.sh`
# And replace the env vars

set -e

MOUNT_PATH=/mnt
NAME=cryptdevice
KEY_PATH=~/usbkey.lek.asc
BLOCK_DEVICE=/dev/disk/by-label/FOO

sudo umount "$MOUNT_PATH" || true
sudo cryptsetup close /dev/mapper/"$NAME" || true

gpg -q --no-symkey-cache -d "$KEY_PATH" | \
  sudo cryptsetup --key-file=- open "$BLOCK_DEVICE" "$NAME"

sudo mount /dev/mapper/"$NAME" "$MOUNT_PATH"
