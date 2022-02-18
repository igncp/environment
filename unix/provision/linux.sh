# linux START

cat >> ~/.shell_aliases <<"EOF"
alias HongKongTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias LinuxLsCPU='lscpu'
alias LinuxLsHardware='lscpi'
alias LinuxLsKernelModules='lsmod'
alias MadridTimezone='sudo timedatectl set-timezone Europe/Madrid'
alias SystemFailed='systemctl --failed'
alias SystemFailedClear='systemctl reset-failed'
alias SystemJournalErrors='sudo journalctl -p 3 -xb'
alias TimeRestartService='sudo systemctl restart systemd-timesyncd.service'
alias TokyoTimezone='sudo timedatectl set-timezone Asia/Tokyo'
EOF

cat >> ~/.shell_aliases <<"EOF"
GrubHideSetupSDA() {
  sudo sed -i 's|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=1|' /etc/default/grub
  sudo sed -i 's|^GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=hidden|' /etc/default/grub
  sudo grub-install /dev/sda
  sudo grub-mkconfig -o /boot/grub/grub.cfg
}
EOF

# LVM
# lvcreate --size 10G -n home ubuntu-vg # use mkfs.ext4 and mount (for fstab) after
# lvdisplay

## Performance

if [ -n "$(grep 1 /proc/sys/kernel/nmi_watchdog)" ] && [ -z "$(grep watchdog /boot/grub/grub.cfg)" ]; then
  if [ ! -f ~/.check-files/watchdog ]; then
    echo "[~/.check-files/watchdog] Add 'nmi_watchdog=0' to grub opts to disable watchdog or hide this message"
  fi
fi

if [ -z "$(grep noatime /etc/fstab)" ] && [ ! -f ~/.check-files/noatime ]; then
  echo "[~/.check-files/noatime] Replace relatime with noatime in fstab or hide this message"
fi

if [ ! -f ~/.check-files/swappiness ]; then
  echo "[~/.check-files/swappiness] Decide wheather to use SwappinessUpdate and hide this message"
fi

cat >> ~/.shell_aliases <<"EOF"
SwappinessUpdate() {
  echo 'vm.swappiness=10' > /tmp/99-swappiness.conf
  echo 'vm.vfs_cache_pressure=50' >> /tmp/99-swappiness.conf
  echo 'vm.dirty_ratio=3' >> /tmp/99-swappiness.conf
  sudo mv /tmp/99-swappiness.conf /etc/sysctl.d/
}
EOF

# https://www.geeksforgeeks.org/iotop-command-in-linux-with-examples
# sudo iotop -o -n 2 -t -b
install_system_package iotop

# @TODO: setup alias for this
# echo '- swap: https://wiki.archlinux.org/index.php/swap'
# echo '    sudo su # can create the swapfile inside the home directory if bigger volume'
# echo '    dd if=/dev/zero of=/swapfile bs=1G count=10 status=progress # RAM size + 2G, in this case 10 GB Swap'
# echo "    chmod 600 /swapfile ; mkswap /swapfile ; swapon /swapfile ; echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab"

if [ ! -f ~/.check-files/oomd ] && [ -n "$(systemctl list-units --full -all | grep systemd-oomd)" ]; then
  sudo systemctl enable --now systemd-oomd
  touch ~/.check-files/oomd
fi

# linux END
