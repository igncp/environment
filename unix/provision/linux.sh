# linux START

install_system_package lshw

if [ -z "$ARM_ARCH" ]; then
  install_system_package dmidecode
  cat >> ~/.shell_aliases <<"EOF"
alias LinuxLsHardwareMemory='sudo dmidecode --type 17'
EOF
fi

cat >> ~/.shell_aliases <<"EOF"
alias JournalctlDiskUsage='sudo journalctl --disk-usage'
alias JournalctlKernel='sudo journalctl -k'
alias JournalctlLsBoots='sudo journalctl --list-boots'
alias JournalctlSystemErrors='sudo journalctl -p 3 -x'
alias JournalctlUnit='sudo journalctl -u' # e.g. JournalctlUnit ufw -b
alias JournalctlUser='sudo journalctl _UID=' # find with `id USER_NAME`

alias LinuxLsCPU='lscpu'
alias LinuxLsHardware='sudo lshw'
alias LinuxLsHardwarePCI='lspci'
alias LinuxLsKernelModules='lsmod'
alias SystemFailed='systemctl --failed'
alias SystemFailedReset='systemctl reset-failed'

alias SystemAnalyzeCriticalChain='systemd-analyze critical-chain'
alias SystemAnalyzePlot='systemd-analyze plot > /tmp/plot.svg && echo "/tmp/plot.svg generated"'
alias SystemAnalyzeTimes='systemd-analyze blame'

alias LsBlkNoLoop='lsblk -e7' # Excludes loop devices, which can accumulate when using snaps: https://askubuntu.com/a/1142405

SystemdFindReference() { sudo grep -r "$1" /usr/lib/systemd/system/; }
EOF

cat >> ~/.shell_aliases <<"EOF"
alias HongKongTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias MadridTimezone='sudo timedatectl set-timezone Europe/Madrid'
alias TimeSyncRestart='sudo systemctl restart systemd-timesyncd.service'
alias TimeSyncShow='timedatectl show-timesync --all'
alias TimeSyncStatus='timedatectl timesync-status'
alias TimezoneShow='timedatectl status'
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

if [ -f /proc/sys/kernel/nmi_watchdog ] && [ -n "$(grep 1 /proc/sys/kernel/nmi_watchdog)" ] && [ -z "$(grep watchdog /boot/grub/grub.cfg)" ]; then
  if [ ! -f ~/.check-files/watchdog ]; then
    echo "[~/.check-files/watchdog]: Add 'nmi_watchdog=0' to grub opts to disable watchdog and hide this message"
  fi
fi

if [ -z "$(grep noatime /etc/fstab)" ] && [ ! -f ~/.check-files/noatime ]; then
  echo "[~/.check-files/noatime]: Replace relatime with noatime in fstab and hide this message"
fi

if [ ! -f ~/.check-files/swappiness ]; then
  echo "[~/.check-files/swappiness]: Decide whether to use SwappinessUpdate and hide this message"
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
