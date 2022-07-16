#!/usr/bin/env bash

set -e

VM_NAME="$1"
ISO_PATH="$2"

MACHINENAME_DISK="disk"

sudo rm -rf ~/.vms/$VM_NAME

VBoxManage createvm \
  --name $VM_NAME \
  --ostype "Debian_64" \
  --register \
  --basefolder ~/.vms/

VBoxManage modifyvm $VM_NAME --ioapic on
VBoxManage modifyvm $VM_NAME --memory 1024 --vram 128
VBoxManage modifyvm $VM_NAME --nic1 nat

VBoxManage createhd --filename ~/.vms/$VM_NAME/$MACHINENAME_DISK.vdi --size 80000 --format VDI
VBoxManage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $VM_NAME \
  --storagectl "SATA Controller" --port 0 --device 0 \
  --type hdd --medium  ~/.vms/$VM_NAME/$MACHINENAME_DISK.vdi
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" \
  --port 1 --device 0 --type dvddrive \
  --medium "$ISO_PATH"
VBoxManage modifyvm $VM_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

VBoxManage modifyvm $VM_NAME --vrde on
VBoxManage modifyvm $VM_NAME --vrdemulticon on --vrdeport 10001
