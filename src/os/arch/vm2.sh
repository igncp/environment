#!/usr/bin/env bash

# This file is intended to be run by the root user in chroot mode, or via SSH in
# an existing UTM VM

# If installing a UTM pre-built VM, first do:
# - Resize the VM in UTM
# - Configure other settings of VM in UTM (network, memory)
# - Use `cfdisk` (already installed) to resize the partition
# - Install `rsync` and clone the environment repo into the machine

set -e

pacman -S git --noconfirm
useradd igncp -m
echo "Change password on login"
echo "igncp:igncp" | chpasswd
pacman -S sudo --noconfirm
echo "# igncp ALL=(ALL) ALL" >>/etc/sudoers
echo "igncp ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers # For the initial installation
echo "alias ll='ls -lah'" >>/home/igncp/.bashrc

ssh-keygen -A

# # Uncomment if installing a vbox VM
# pacman -S --noconfirm virtualbox-guest-utils
# usermod -G vboxsf -a igncp
# systemctl enable vboxservice.service

# # Uncomment if not UTM pre-built VM
# pacman -S --noconfirm dhcpcd
# pacman -S --noconfirm openssh rsync
# systemctl enable dhcpcd.service
# systemctl enable sshd.service
# systemctl enable --now systemd-resolved.service

pacman -S --noconfirm ufw

systemctl enable --now systemd-timesyncd.service

sed -i 's|#en_US\.UTF|en_US.UTF|' /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8

# Change the default `umask` to be more restrictive
sed -i 's|^umask.*|umask 0077|' /etc/profile

pacman -S --noconfirm apparmor

# alternative: sudo journalctl --vacuum-size=500M
journalctl --vacuum-time=10d

cp /root/.vimrc /home/igncp/.vimrc || true
chown -R igncp:igncp /home/igncp/.vimrc || true

# https://wiki.archlinux.org/title/security#Mount_options
chmod -R 700 /boot /etc/iptables

echo 'FONT=latarcyrheb-sun32' >/etc/vconsole.conf

chown -R igncp:igncp /home/igncp/
rm -f ~/vm2.sh || true
