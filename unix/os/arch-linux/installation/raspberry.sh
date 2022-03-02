#!/bin/bash

set -e

# Setup SD Card:
    # - Raspberry Pi 4: https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
    # - Raspberry Pi 3: https://archlinuxarm.org/platforms/armv6/raspberry-pi

# Create volume for home directory, which will be encrypted and not mounted during boot

# Before disconnecting the SD from computer:
    # - copy the wifi password inside the PI

# on the RP, connected via ethernet
# ssh-copy-id -i ~/.ssh/local-asus alarm@raspberry
# ssh alarm@raspberry # password: alarm
# scp this file into the PI
    # rsync -rhv . alarm@raspberry:/home/igncp/environment

# Run this as root

echo 'Remember to update the disk to encrypt before running'

read -p "Do you want to continue? (yY) " -n 1 -r; echo ''; if ! [[ $REPLY =~ ^[Yy]$  ]]; then exit; fi

if [ -z "$(whoami | grep root || true)" ]; then
  echo 'You should run this command as the root'
  exit 1
fi

if [ ! -d /home/alarm/.ssh/authorized_keys ]; then
  echo 'You have to run ssh-copy-id before'
  exit 1
fi

useradd igncp -m

echo "Change alarm password"
passwd alarm
echo "Change root password"
passwd
echo "Change igncp password"
passwd igncp

rm -rf /home/igncp/.*
cryptsetup -q -y -v luksFormat /dev/mmcblk0p3
cryptsetup open /dev/mmcblk0p3 crypthome
mkfs.ext4 /dev/mapper/crypthome
mount /dev/mapper/crypthome /home/igncp
echo "igncp ALL=(ALL) ALL" >> /etc/sudoers
echo "alarm ALL=(ALL) ALL" >> /etc/sudoers
echo "alias ll='ls -lah'" >> /home/igncp/.bashrc
cp -r /home/alarm/.ssh /home/igncp/
chown -R igncp:igncp /home/igncp
sed -i 's|#PasswordAuthentication.*|PasswordAuthentication no|' /etc/ssh/sshd_config
systemctl restart sshd

cat > /home/alarm/mount_igncp.sh <<"EOF"
#!/bin/bash

set -e

sudo cryptsetup open /dev/mmcblk0p3 crypthome
sudo mount /dev/mapper/crypthome /home/igncp
EOF
chown alarm:alarm /home/alarm/mount_igncp.sh
chmod +x /home/alarm/mount_igncp.sh

pacman-key --init
pacman-key --populate archlinuxarm
pacman -Sy
pacman -S vim --noconfirm
pacman -S git --noconfirm
pacman -S sudo --noconfirm
pacman -S rsync --noconfirm
pacman -S ufw --noconfirm

ufw allow ssh

# https://archlinuxarm.org/forum/viewtopic.php?f=57&t=15463#p67275
systemctl enable systemd-timesyncd.service
systemctl restart systemd-networkd
systemctl enable ufw

sed -i 's|#en_US\.UTF|en_US.UTF|' /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8

# alternative: sudo journalctl --vacuum-size=500M
journalctl --vacuum-time=10d

# Remote desktop work
  # RP RDP (new session)
    # yay -S xrdp
    # yay -S xorgxrdp
    # sudo systemctl enable --now xrdp
    # allowed_users=anybody to /etc/X11/Xwrapper.config
    # sudo ufw allow 3389
    # install lxde
  # RP VNC (same session)
    # sudo pacman -S x11vnc
    # nohup x11vnc -many -display :0 & ; nohup startx &
    # DISPLAY=:0.0 xrandr --output HDMI-1 --mode 1920x1080
    # sudo pacman -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth bluez bluez-utils
    # https://gist.github.com/frankgould/db38ca5e40b3d2368f8d7765e346f8c5
    # Fixed: https://askubuntu.com/a/1171274
    # Fixed HDMI: install more alsa packages and add user to audio group: https://askubuntu.com/a/1173748
    # For HDMI, it needs to use the misi USB closest to the power
    # sudo ufw allow 5900
  # RP Network
    # Network: sudo systemctl enable netctl@elcano.service (make sure is the only profile enabled)
  # Host clients
    # XRDP: sudo pacman -S remmina freerdp
    # VNC: sudo pacman -S tigervnc

#!/bin/bash
# set -e
# nohup startx &
# sleep 10
# # x11vnc -storepasswd # saves the password in ~/.vnc/passwd
# nohup x11vnc -usepw -display :0 &
# DISPLAY=:0.0 xrandr --output HDMI-1 --mode 1920x1080

echo "Run vm3.sh"
