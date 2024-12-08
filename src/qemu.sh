#!/bin/bash

set -e

provision_setup_qemu() {
  # `virsh` 係一個用嚟管理虛擬機器嘅命令行介面工具

  if [ -f "$PROVISION_CONFIG"/qemu ]; then
    if [ ! -f /etc/qemu/bridge.conf ] && [ "$IS_DEBIAN" = "1" ]; then
      if [ -n "$(cat /etc/passwd | grep libvirt-qemu || true)" ]; then
        sudo /usr/sbin/usermod -a -G netdev libvirt-qemu
      fi
      if [ -f /usr/lib/qemu/qemu-bridge-helper ]; then
        sudo chmod +s /usr/lib/qemu/qemu-bridge-helper
      fi
      sudo mkdir -p /etc/qemu
      sudo bash -c 'echo "allow virbr0" > /etc/qemu/bridge.conf'
      sudo chown root:kvm /etc/qemu/bridge.conf
      sudo chmod 0660 /etc/qemu/bridge.conf
      echo "allow all" | sudo tee /etc/qemu/${USER}.conf
      echo "include /etc/qemu/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
      sudo chown root:${USER} /etc/qemu/${USER}.conf
      sudo chmod 640 /etc/qemu/${USER}.conf
    fi
  fi

  # 確保你將用戶加入「 kvm 」同「 netdev 」群組
  cat >>~/.shell_aliases <<"EOF"
QemuDebianInstall() {
  sudo apt install --no-install-recommends \
    qemu-system qemu-utils qemu-system-x86 qemu-kvm \
    libvirt-clients libvirt-daemon-system libguestfs-tools
}
alias QemuCreateImage='qemu-img create -f qcow2 alpine.qcow2 16G'
QemuStart() {
  qemu-system-x86_64 \
    -enable-kvm \
    -name arch-linux \
    -m 4G \
    -smp 4 \
    -cpu host \
    -hda ./alpine.qcow2 \
    -cdrom ./archlinux-2024.11.01-x86_64.iso \
    -nic user,hostfwd=tcp::60022-:22
}
alias QemuListFS='virt-filesystems --long -h --all -a'
alias QemuImageInfo='qemu-img info'
EOF
}
