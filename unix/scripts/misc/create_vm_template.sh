#!/usr/bin/env bash

set -ex

## The steps for creating a new VM:
## - Copy this file, with `vm1.sh`, `vm2.sh`, and `vm3.sh` (if present)
## - Review and edit all scripts

VM_NAME="test-environment"
ISO_PATH="$HOME"/Downloads/archlinux.iso
MEMORY="8192"
DISK_SIZE="20000"
MACHINENAME_DISK_PATH="$HOME/.vms/$VM_NAME/disk.vdi"
CPUS_NUM=4
ENVIRONMENT_PATH="$HOME/development/environment"
BRIDGE_ADAPTER="" # Find with `vboxmanage list vms -l | grep -i bridge`
OS_TYPE=ArchLinux_64 # `vboxmanage list ostypes`

if ! type sshpass > /dev/null 2>&1 ; then
  echo "sshpass is required"
  exit 1
fi

if [ -z "$BRIDGE_ADAPTER" ]; then
  echo "BRIDGE_ADAPTER needs to be set"
  exit 1
fi

if [ ! -f "$ISO_PATH" ]; then
  wget https://mirror.librelabucm.org/archlinux/iso/latest/archlinux-x86_64.iso -O "$ISO_PATH"
fi

EXISTING_VM=$(vboxmanage list vms | ag -F '"'"$VM_NAME"'"' || true)

if [ -n "$EXISTING_VM" ]; then
  VBoxManage unregistervm "$VM_NAME" --delete
fi

EXISTING_DISK=$(vboxmanage list hdds | ag -F "$MACHINENAME_DISK_PATH" || true)

if [ -n "$EXISTING_DISK" ]; then
  vboxmanage closemedium disk --delete "$MACHINENAME_DISK_PATH"
fi

sudo rm -rf $HOME/.vms/$VM_NAME

VBoxManage createvm \
  --name $VM_NAME \
  --ostype "$OS_TYPE" \
  --register \
  --basefolder $HOME/.vms/

VBoxManage modifyvm $VM_NAME --ioapic on
VBoxManage modifyvm $VM_NAME \
  --memory "$MEMORY" \
  --vram 128
VBoxManage modifyvm $VM_NAME --cpus "$CPUS_NUM"

# VBoxManage modifyvm $VM_NAME --nic1 nat
VBoxManage modifyvm $VM_NAME --nic1 bridged
VBoxManage modifyvm $VM_NAME --bridgeadapter1 "$BRIDGE_ADAPTER"

# Fixed is slower but better for performance
VBoxManage createhd \
  --filename "$MACHINENAME_DISK_PATH" \
  --size "$DISK_SIZE" \
  --variant Fixed \
  --format VDI

VBoxManage storagectl $VM_NAME --name "SATA Controller $VM_NAME" --remove || true
VBoxManage storagectl $VM_NAME --name "SATA Controller $VM_NAME" --add sata --controller IntelAhci

VBoxManage storageattach $VM_NAME \
  --storagectl "SATA Controller $VM_NAME" --port 0 --device 0 \
  --type hdd --medium  "$MACHINENAME_DISK_PATH"

VBoxManage storagectl $VM_NAME --name "IDE Controller $VM_NAME" --remove || true
VBoxManage storagectl $VM_NAME --name "IDE Controller $VM_NAME" --add ide --controller PIIX4

VBoxManage storageattach $VM_NAME \
  --storagectl "IDE Controller $VM_NAME" \
  --port 1 --device 0 --type dvddrive \
  --medium "$ISO_PATH"

VBoxManage modifyvm $VM_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

VBoxManage modifyvm $VM_NAME --vrde on
VBoxManage modifyvm $VM_NAME --usb on # Allow USB in VMs
VBoxManage modifyvm $VM_NAME --vrdemulticon on --vrdeport 10001

VBoxManage startvm "$VM_NAME" --type gui

# @TODO: Try with shared clipboard and pasting the command
echo "Set the root password and press the 'q' key when ready"
while : ; do read -n 1 k <&1
  if [[ $k = q ]] ; then break; fi
done

IP=$(VBoxManage guestproperty enumerate "$VM_NAME" | ag IP | ag -o '192.168.1.[0-9]*')

# To run over ssh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sshpass -p root scp "$SCRIPT_DIR/vm1.sh" "root@$IP":/root/
sshpass -p root scp "$SCRIPT_DIR/vm2.sh" "root@$IP":/root/
if [ -f "$SCRIPT_DIR/vm3.sh" ]; then
  sshpass -p root scp "$SCRIPT_DIR/vm3.sh" "root@$IP":/root/
fi

sshpass -p root ssh "root@$IP" /root/vm1.sh

sshpass -p root ssh "root@$IP" 'shutdown now'

echo "Waiting 20s until machine shuts down"
sleep 20

VBoxManage storageattach $VM_NAME \
  --storagectl "IDE Controller $VM_NAME" \
  --port 1 --device 0 --type dvddrive \
  --medium none

VBoxManage startvm "$VM_NAME" --type gui

echo "Wait for the VM to reboot and then press 'q'"
while : ; do read -n 1 k <&1
  if [[ $k = q ]] ; then break; fi
done

IP=$(VBoxManage guestproperty enumerate "$VM_NAME" | ag IP | ag -o '192.168.1.[0-9]*')

sshpass -p igncp scp \
  -r "$ENVIRONMENT_PATH" "igncp@$IP":/home/igncp/environment

sshpass -p igncp ssh "igncp@$IP" << EOF
cd ~
sh vm3.sh
sh project/provision/provision.sh
EOF
