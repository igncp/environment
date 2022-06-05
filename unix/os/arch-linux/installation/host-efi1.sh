#!/usr/bin/env bash

# Installation scripts for UEFI Boot as host
# Follow VM installation, adding here only the different parts

# Windows: Use UUI to setup a Live USB: https://www.pendrivelinux.com/universal-usb-installer-easy-as-1-2-3/
# Linux: Use dd: https://wiki.archlinux.org/index.php/USB_flash_installation_media
    # e.g.: sudo dd bs=4M if=path/to/arch.iso of=/dev/sdb conv=fsync oflag=direct status=progress

# Can connect to WIFI after partitioning disks so you can save the password in file in disk
# If you have an additional USB port and stick, or additional internal drive, can copy it there:
    # iwctl --passphrase=PASS station DEVICE connect SSID ; sleep 5 ; ping archlinux.org

# Check the machine BIOS key

# Manage partitions
    # Use cfdisk /dev/nvme0n1 # if using other type of drive
    # Choose to delete all
    # Create a new one of type EFI System (500M).

# If existing partitions, can just clear them
    # dd if=/dev/zero of=/dev/mapper/cryptroot bs=4096 status=progress

# disable annoying bell
setterm -blength 0

# increase font size
setfont /usr/share/kbd/consolefonts/ter-132n.psf.gz

# troubleshoot network
rfkill list # if wifi is softblocked, try pressing the airplane key

# connect to internet
# dhcpcd # needed in some cases
iwctl # https://wiki.archlinux.org/index.php/Iwd#iwctl
  # device list
  # station DEVICE show # needs to be powered on
  # station DEVICE get-networks
  # station DEVICE connect SSID
ping archlinux.org # to confirm that network works
# ip a | grep 192 # get the ip
# rsync -r ./unix/os/arch-linux/installation/ root@192.168.1.x:/root/
# after this, can run some parts of this script with shell via ssh

mkfs.fat -F32 /dev/sda1 # Boot partition
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# inside arch-chroot session
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
pacman -S --noconfirm netctl dialog wpa_supplicant dhcpcd # for wifi-menu
# don't enable dhcpcd.service as it doesn't work well with netctl

grub-install /dev/DEVICE --target=x86_64-efi --bootloader-id=grub_uefi --recheck --efi-directory=/boot # replace DEVICE, e.g. /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
# If installing a multi-boot Linux, the last EFI run is the one that will be
# used. Best is to run it three times, once per OS (2) and finally again for the
# first one (3rd one)

# If dual-boot Windows and Arch, before running `grub-mkconfig` from Linux, in
# `/etc/default/grub` uncomment the line where `GRUB_DISABLE_OS_PROBER=false`.
# After that, it should add an entry for the Windows bootloader.
# https://wiki.archlinux.org/title/GRUB#Detecting_other_operating_systems

# Disable laptop beep sound
echo 'blacklist pcspkr' > /tmp/nobeep.conf; mv /tmp/nobeep.conf /etc/modprobe.d/nobeep.conf
rmmod pcspkr # only for current session

sed -i 's|#HandleLidSwitchExternalPower=.*|HandleLidSwitchExternalPower=ignore|' /etc/systemd/logind.conf
