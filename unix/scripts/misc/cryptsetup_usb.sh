#!/usr/bin/env bash

# This is WIP

set -e

# https://tqdev.com/2022-luks-with-usb-unlock
# https://gist.github.com/da-n/4c77d09720f3e5989dd0f6de5fe3cbfb

# /etc/udev/rules.d/99-custom-usb.rules
# SUBSYSTEMS=="usb", DRIVERS=="usb",SYMLINK+="usbdevice%n"
udevadm control --reload-rules

dd if=/dev/urandom bs=1 count=256 > usbkey.lek
sudo cryptsetup luksAddKey /dev/sda3 usbkey.lek
cp usbkey.lek /usb_mnt
