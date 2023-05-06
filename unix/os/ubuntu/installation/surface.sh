# Initial instructions in: `unix/os/arch-linux/installation/surface.sh`

# https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup

# Copy Ubuntu Desktop LTS

# Press and hold the volume-down button on the Surface. While you're doing
# this, press and release the power button. Or if from Windows, can boot from
# the settings like explained in `unix/os/arch-linux/installation/surface.sh`

# Choose:
  # - Minimal installation (browser and basic utilities)
  # - LVM with encryption

# Install updates after first boot
# Enable SSH if configured: `sudo apt-get install -y openssh-server && sudo systemctl enable --now sshd.service`
sudo apt-get install -y git vim curl build-essential && git clone https://github.com/igncp/environment
sudo apt-get install -y extrepo
sudo extrepo enable surface-linux && sudo apt update
sudo apt install -y linux-image-surface linux-headers-surface libwacom-surface iptsd
sudo apt install -y linux-surface-secureboot-mok
sudo update-grub

# Follow post-installation steps: https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup#post-installation

# After this point, install normally from './vm2.sh'

# Can swap keys with hwdb:
# https://askubuntu.com/questions/1374276/swap-some-keyboard-keys
  # Example for: `/etc/udev/hwdb.d/99-keyboard.hwdb`
    # evdev:name:Microsoft Surface Keyboard:*
    #  KEYBOARD_KEY_70064=grave
  # To apply: `sudo systemd-hwdb update ; sudo udevadm trigger`

# To hide desktop icons:
  # `sudo apt install gnome-shell-extension-prefs`
  # Open the extensions app

# For the camera:
  # https://libcamera.org/getting-started.html

# Install a patched font for the dev icons:
  # https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Monofur/Regular

# Don't forget to setup SSH, VPNs and the firewall
