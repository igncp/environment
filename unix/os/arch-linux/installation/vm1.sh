#!/usr/bin/env bash

set -e
set -x

# This file is intended to be copied, edited and run automatically

# Download Arch Linux ISO image
# https://archlinux.org/download/
# ARM: https://pkgbuild.com/~tpowa/archboot-images

# Setup bridged adaptor network to make things easier

# You can use automatic VM creation script

# if possible connect via SSH from host (SSH is already enabled)
  # ip a | grep -i 192 ; passwd

# From the host
  # sed -i '/192.168.1.X/d' ~/.ssh/known_hosts
  # ssh root@192.168.1.X # to confirm
  # rsync -rhv ./unix/os/arch-linux/installation/ root@192.168.1.X:/root/
      # If using windows, you can use scp
  # ssh root@192.168.1.X
  # echo 'syntax off' > /root/.vimrc ; echo 'set mouse-=a' >> /root/.vimrc

# If LVM already exists, can remove some of them, for example: lvremove /dev/mapper/arch-lvroot

# Choose GPT type
# - If BIOS, add a BIOS boot partition of 1M. If encrypting, create another one unencrypted for `/boot` with 500M. Can also be created later inside LVM, but don't forget to mount it before grub-install`
# - If EFI, add an EFI partition (and format it to vfat) with 500M. Use this as `/boot` (not encrypted)
cfdisk /dev/sda

read -p "Do you want to continue? (yY) " -n 1 -r; echo ''; if ! [[ $REPLY =~ ^[Yy]$  ]]; then exit; fi

# Encryption: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system
  cryptsetup -y -v luksFormat /dev/sda3 # For LVM: VG_NAME-LVNAME
  # if want to change the password after: sudo cryptsetup luksChangeKey /dev/mapper/BLOCK_NAME
  cryptsetup open /dev/sda3 CRYPT_NAME
  mkfs.ext4 /dev/mapper/CRYPT_NAME # Not necessary if adding LVM in it

# LVM setup: https://wiki.archlinux.org/index.php/Install_Arch_Linux_on_LVM
  # if info of volumes broken and data can be discarded: wipefs --all /dev/sda; pvscan --cache
  # to debug: `pvscan`, `lvdisplay`
  pvcreate /dev/mapper/CRYPT_NAME
  vgcreate VG_NAME /dev/mapper/CRYPT_NAME
  lvcreate -L 20G VG_NAME -n LV_NAME_1
  lvcreate -l 100%FREE VG_NAME -n LV_NAME_2
  vgchange -ay
  modprobe dm_mod
  # lvs are in /dev/arch/...

mkfs.ext4 /dev/mapper/BLOCK_NAME
mount /dev/mapper/BLOCK_NAME /mnt
mkdir -p /mnt/etc /mnt/boot /mnt/home

# Format and mount boot and home if necessary:
  mkfs.vfat /dev/sda1
  mkfs.ext4 /dev/mapper/BLOCK_NAME
  mount /dev/sda1 /mnt/boot
  mount /dev/mapper/BLOCK_NAME /mnt/home

# mount /boot, /home, or others if necessary
genfstab -U /mnt >> /mnt/etc/fstab

pacstrap /mnt base linux linux-firmware vim # downloads ~300 MB
cp -r /root/* /root/.vimrc /mnt/root/

cat > /mnt/root/init.sh <<"EOF"
#!/usr/bin/env bash

set -e
set -x

pacman -Syy
pacman -S --noconfirm grub

# if encryption or / and LVM
  # cryptdevice=UUID=device-UUID:cryptroot # retrieved from `blkid`
  # example for crypttab (not necessary if single encrypted partition):
    # 'crypthome         UUID=2f9a8428-ac69-478a-88a2-4aa458565431        none'
  # these HOOKS are for LVM and encryption
    sed -i 's|^HOOKS=.*$|HOOKS=(base udev autodetect keyboard keymap consolefont modconf block lvm2 encrypt filesystems fsck)|' /etc/mkinitcpio.conf
  vim -p /etc/default/grub /etc/crypttab
  pacman -S --noconfirm lvm2 # if LVM, should already run mkinitcpio below
  # mkinitcpio -p linux # only necessary if didn't run command above

read -p "Do you want to continue? (yY) " -n 1 -r; echo ''; if ! [[ $REPLY =~ ^[Yy]$  ]]; then exit; fi

vim /root/vm2.sh # modify anything not necessary
echo 'sh /root/vm2.sh'
rm -rf /root/init.sh
EOF

echo '/root/init.sh created'

read -p "Do you want to continue? (yY) " -n 1 -r; echo ''; if ! [[ $REPLY =~ ^[Yy]$  ]]; then exit; fi

arch-chroot /mnt
