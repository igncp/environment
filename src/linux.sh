#!/usr/bin/env bash

set -e

. src/linux/apk.sh
. src/linux/gui.sh
. src/linux/gui_apps.sh

provision_setup_linux() {
  if [ "$IS_LINUX" != "1" ]; then
    return
  fi

  cat >>~/.shellrc <<"EOF"
export PATH="$PATH:/usr/sbin"
EOF

  install_system_package "lshw"
  install_system_package "dmidecode"

  cat >>~/.shell_aliases <<"EOF"
alias systemctl='systemctl --user'

alias LinuxLsHardwareMemory='sudo dmidecode --type 17'

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

FACLRemoveGroupForFile() { sudo setfacl -x g:$1 $2 ; }

alias LsBlkNoLoop='lsblk -e7' # Excludes loop devices, which can accumulate when using snaps: https://askubuntu.com/a/1142405
alias LsInitRAMFS='lsinitcpio /boot/initramfs-linux.img'

alias LabelEXTPartition='sudo e2label' # For example: LabelEXTPartition /dev/sda2 FOO_NAME
alias LabelFAT='sudo fatlabel' # For example: LabelFAT /dev/sda2 FOO_NAME
LabelLuksPartition() { sudo cryptsetup config $1 --label $2; } # For example: LabelLuksPartition /dev/sda2 FOO_NAME

SystemdFindReference() { sudo grep -r "$1" /usr/lib/systemd/system/; }

# Example: TOTP ~/foo-topt.gpg
TOTP() {
  KEY=$(sudo gpg -q -d --pinentry-mode=loopback --no-symkey-cache $1)
  if [ -z "$KEY" ]; then echo "Invalid key"; return; fi
  VALUE=$(oathtool --totp -b "$KEY");
  echo "$VALUE" ; echo "$VALUE" | tr -d '\n' | xclip -selection clipboard
}

alias HongKongTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias MadridTimezone='sudo timedatectl set-timezone Europe/Madrid'
alias TimeSyncRestart='sudo systemctl restart systemd-timesyncd.service'
alias TimeSyncShow='timedatectl show-timesync --all'
alias TimeSyncStatus='timedatectl timesync-status'
alias TimezoneShow='timedatectl status'
alias TokyoTimezone='sudo timedatectl set-timezone Asia/Tokyo'

GrubHideSetupTimeout() {
  sudo sed -i 's|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=1|' /etc/default/grub
  sudo sed -i 's|^GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=hidden|' /etc/default/grub
}

LinuxSwappinessUpdate() {
  echo 'vm.swappiness=10' > /tmp/99-swappiness.conf
  echo 'vm.vfs_cache_pressure=50' >> /tmp/99-swappiness.conf
  echo 'vm.dirty_ratio=3' >> /tmp/99-swappiness.conf
  sudo mv /tmp/99-swappiness.conf /etc/sysctl.d/
}
EOF

  # https://www.geeksforgeeks.org/iotop-command-in-linux-with-examples
  # sudo iotop -o -n 2 -t -b
  install_system_package "iotop"

  if [ ! -f ~/.check-files/swappiness ]; then
    echo "[~/.check-files/swappiness]: Decide whether to use SwappinessUpdate and hide this message"
  fi

  # LVM
  # Creation: lvcreate --size 10G -n home ubuntu-vg # use mkfs.ext4 and mount (for fstab) after
  # For extending: lvextend -L +8G /dev/mapper/lv-foo ; resize2fs /dev/mapper/lv-foo
  # lvdisplay

  # Performance
  if [ -f /proc/sys/kernel/nmi_watchdog ]; then
    if [ ! -f ~/.check-files/watchdog ]; then
      if [ -n "$(grep 1 /proc/sys/kernel/nmi_watchdog)" ] && [ -f /boot/grub/grub.cfg ] && [ -z "$(sudo grep watchdog /boot/grub/grub.cfg)" ]; then
        echo "[~/.check-files/watchdog]: Add 'nmi_watchdog=0' to the kernel params in grub to disable watchdog or hide this message"
      fi
    fi
  fi

  if [ ! -f ~/.check-files/noatime ]; then
    if [ -f /etc/fstab ] && [ -n "$(grep relatime /etc/fstab || true)" ]; then
      echo "[~/.check-files/noatime]: Replace relatime with noatime in fstab and hide this message"
    fi
  fi

  install_system_package "strace"

  mkdir -p ~/.gnupg

  echo "pinentry-program /usr/bin/pinentry-tty" >~/.gnupg/gpg-agent.conf

  # Disable the PC loud beep
  if [ ! -f /etc/modprobe.d/nobeep.conf ]; then
    echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/nobeep.conf
  fi

  if [ "$IS_NIXOS" != "1" ]; then
    if [ -f "$PROVISION_CONFIG"/tailscale ] && [ ! -f ~/.check-files/tailscale ]; then
      curl -fsSL https://tailscale.com/install.sh | sh

      if [ -n "$(sudo systemctl list-units | grep tailscaled || true)" ]; then
        sudo systemctl enable --now tailscaled
      else
        sudo systemctl enable --now tailscale
      fi

      touch ~/.check-files/tailscale
    fi
  fi

  provision_setup_linux_apk
  provision_setup_linux_gui_apps
}
