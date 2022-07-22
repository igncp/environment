#!/usr/bin/env bash

set -e
set -x

# This file is intended to be copied, edited and run automatically

# Download Arch Linux ISO image
# https://archlinux.org/download/
# ARM: https://pkgbuild.com/~tpowa/archboot-images

# You can use automatic VM creation script in unix/scripts/misc/create_vm_template.sh

# If LVM already exists, can remove some of them, for example: lvremove /dev/mapper/arch-lvroot

# Choose GPT type
# - If BIOS, add a BIOS boot partition of 1M. If encrypting, create another one unencrypted for `/boot` with 500M. Can also be created later inside LVM, but don't forget to mount it before grub-install`
# - If EFI, add an EFI partition (and format it to vfat) with 500M. Use this as `/boot` (not encrypted)
# cfdisk /dev/sda

# Automated for BIOS VM
echo -e "g\nn\n1\n\n+1M\nt\n4\nn\n2\n\n\np\nw"| fdisk /dev/sda

read -p "Do you want to continue? (yY) " -n 1 -r; echo ''; if ! [[ $REPLY =~ ^[Yy]$  ]]; then exit; fi

# Encryption: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system
  # Considering using a USB device to decrypt on boot: https://gist.github.com/da-n/4c77d09720f3e5989dd0f6de5fe3cbfb
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

# Format and mount boot and home if necessary:
  mkfs.vfat /dev/sda1
  mkfs.ext4 /dev/mapper/BLOCK_NAME

mkfs.ext4 /dev/mapper/BLOCK_NAME
mount /dev/mapper/BLOCK_NAME /mnt
mkdir -p /mnt/etc /mnt/boot /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/mapper/BLOCK_NAME /mnt/home
genfstab -U /mnt >> /mnt/etc/fstab

pacstrap /mnt base linux linux-firmware vim perl # downloads ~300 MB (vim needs perl)
echo 'syntax off' > /root/.vimrc ; echo 'set mouse-=a' >> /root/.vimrc
cp -r /root/* /root/.vimrc /mnt/root/

cat > /mnt/root/init.sh <<"EOF"
#!/usr/bin/env bash

set -e
set -x

pacman -Syy
pacman -S --noconfirm grub

# To complete when automating encryption: BLKID=$(blkid | grep -F '/dev/sda2' | grep '\bUUID=[^ ]*' -o)
# If encryption or / and LVM
  # cryptdevice=UUID=device-UUID:cryptroot # retrieved from `blkid`
  # example for crypttab (not necessary if single encrypted partition):
    # 'crypthome         UUID=2f9a8428-ac69-478a-88a2-4aa458565431        none'
  # these HOOKS are for LVM and encryption
    sed -i 's|^HOOKS=.*$|HOOKS=(base udev autodetect keyboard keymap consolefont modconf block lvm2 encrypt filesystems fsck)|' /etc/mkinitcpio.conf
  vim -p /etc/default/grub /etc/crypttab
  pacman -S --noconfirm lvm2 # if LVM, should already run mkinitcpio below
  # mkinitcpio -p linux # only necessary if didn't run command above

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

rm /root/init.sh /root/vm1.sh
sh /root/vm2.sh
EOF

arch-chroot /mnt bash -c 'sh /root/init.sh'
