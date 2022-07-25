#!/usr/bin/env bash

# This is WIP

set -e

# https://tqdev.com/2022-luks-with-usb-unlock
# https://gist.github.com/da-n/4c77d09720f3e5989dd0f6de5fe3cbfb
# https://gist.github.com/firecat53/17b3d309ea54a0ed0cd4

# /etc/udev/rules.d/99-custom-usb.rules
# SUBSYSTEMS=="usb", DRIVERS=="usb",SYMLINK+="usbdevice%n"
udevadm control --reload-rules

dd if=/dev/urandom bs=1 count=256 > usbkey.lek
sudo cryptsetup luksAddKey /dev/sda3 usbkey.lek
cp usbkey.lek /usb_mnt

sed -i 's|^MODULES=.*$|MODULES=(ext4)|' /etc/mkinitcpio.conf # If USB is formatted as ext4
sed -i 's|^HOOKS=.*$|HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)|' /etc/mkinitcpio.conf
mkinitcpio -p linux

UUID=$(blkid | grep -F '/sda3' | grep -o '\bUUID="[^"]*"' | sed 's|"||g')
USB_ID=$(blkid | grep -F '/sdb1' | grep -o '\bUUID="[^"]*"' | sed 's|"||g')
sed -i 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="cryptdevice='$UUID':cryptroot cryptkey='$USB_ID':ext4:/usbkey.lek"|' /etc/default/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
