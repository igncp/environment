#!/usr/bin/env bash

set -e

# set -x # Uncomment for debugging

# Create the environment
  # Check the region of the environment to be able to attach the respective volumes
  # After creation, copy the IP and update it in `/etc/hosts` and attach the volume

# `create_droplet.sh`

# With digital ocean
  doctl compute droplet create \
    --image ubuntu-22-04-x64 \
    --size ... \
    --region ... \
    --volumes ... \
    --ssh-keys ... \
    --droplet-agent=false \
    --wait \
    sample-env
  # doctl compute size list | less -S
  # doctl compute region list | less -S
  # doctl compute volume list | less -S

echo 'Update the IP in /etc/hosts'

# `prepare_root.sh`

# Replace:
# - REMOTE_HOSTNAME
# - PORT
# - SSH_KEY_PATH

sed -i '/REMOTE_HOSTNAME/d' ~/.ssh/known_hosts

ssh -p 22 root@REMOTE_HOSTNAME -i SSH_KEY_PATH bash <<EOF
# Remember to allow the port in the local machine too
sudo sed -i 's|#Port .*|Port PORT|' /etc/ssh/sshd_config
ufw allow in from any to any port PORT comment 'SSH port'
sudo systemctl restart sshd

ufw default deny outgoing
ufw default deny incoming
ufw allow out to any port 80
ufw allow out to any port 443
ufw allow out to any port 53
ufw --force enable

echo 'umask 0077' >> /etc/profile

# @TODO: Automate TOTP with libpam-google-authenticator
# https://gist.github.com/troyfontaine/926ed27a4fe1c17507fd
apt-get update
apt-get install -y libpam-google-authenticator

# If it is using a fresh volume, set it up first
  cfdisk /dev/sda # Create the /dev/sda1 partition (and others if necessary)
  # At this point only add password # @TODO use a random key in an encrypted file for decryption later
  cryptsetup -y -v luksFormat /dev/sda1
  cryptsetup open /dev/sda1 cryptmain
  mkfs.ext4 /dev/mapper/cryptmain
  cryptsetup close cryptmain

echo 'igncp ALL=(ALL) ALL' >> /etc/sudoers
EOF

ssh -t -p PORT root@REMOTE_HOSTNAME -i SSH_KEY_PATH "useradd -m igncp ; echo 'Password for igncp' ; passwd igncp"

ssh -t -p PORT root@REMOTE_HOSTNAME -i SSH_KEY_PATH "useradd -m init ; echo 'Password for init' ; passwd init"

ssh -p PORT root@REMOTE_HOSTNAME -i SSH_KEY_PATH bash <<EOF
echo 'cryptsetup open /dev/sda1 cryptmain ; mount /dev/mapper/cryptmain /home/igncp' > /home/init/init.sh
chmod 701 /home/init/init.sh ; chown root:root /home/init/init.sh
echo 'init ALL=(ALL) /home/init/init.sh' >> /etc/sudoers
echo 'init ALL=(ALL) /usr/sbin/reboot' >> /etc/sudoers
cp -r /root/.ssh /home/igncp/.ssh ; chown -R igncp:igncp /home/igncp/
cp -r /root/.ssh /home/init/.ssh ; chown -R init:init /home/init

chsh igncp -s /usr/bin/bash ; chsh init -s /usr/bin/bash

# Disable TTYs so the server can't be easily accessed from a physical terminal
# If something goes wrong in the environment and can't login via SSH, will have
# to create a new one
sed 's|#NAutoVTs=.*|NAutoVTs=0|' -i /etc/systemd/logind.conf
sed 's|#ReserveVT=.*|ReserveVT=0|' -i /etc/systemd/logind.conf
systemctl disable --now getty@tty1.service
systemctl restart systemd-logind.service
systemctl stop "getty@tty*.service"
EOF

# `prepare_igncp.sh`

# Replace:
# - REMOTE_HOSTNAME
# - PORT
# - SSH_KEY_PATH
# - PATH_TO_ENVIRONMENT
# - SWAP_NUM

rsync -e 'ssh -i SSH_KEY_PATH -p PORT' -rhv --delete PATH_TO_ENVIRONMENT/ \
  igncp@REMOTE_HOSTNAME:/home/igncp/environment/

ssh -p PORT igncp@REMOTE_HOSTNAME -i SSH_KEY_PATH bash <<EOF
set -e
sudo sed -i 's|^PermitRootLogin yes|PermitRootLogin no|' /etc/ssh/sshd_config
sudo sed -i 's|^PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config

sudo systemctl restart sshd
sudo systemctl disable --now snapd ; sudo systemctl disable --now snapd.socket
sudo apt-get purge -y droplet-agent || true

# Only the first time setting up the volume
  sudo cryptsetup open /dev/sda1 cryptmain
  cd /home ; sudo mv igncp igncp-tmp ; sudo mkdir igncp
  sudo mount /dev/mapper/cryptmain igncp
  sudo rsync -rhv --delete igncp-tmp/ igncp/
  sudo rm -rf igncp-tmp/ ; sudo chown -R igncp:igncp igncp/
  mkdir -p ~/project/.config
  echo 'REMOTE_HOSTNAME' > ~/project/.config/ssh-notice
  # touch ~/project/.config/gui-install # Opt-in GUI
  sh /home/igncp/environment/unix/os/ubuntu/installation/remote_env2.sh
  sudo umount /home/igncp ; sudo cryptsetup close cryptmain
# If not the first time
  sudo rm -rf /home/igncp ; sudo mkdir -p /home/igncp ; sudo chown -R igncp:igncp /home/igncp

sudo cryptsetup open /dev/sda1 cryptmain ; sudo mount /dev/mapper/cryptmain /home/igncp

sudo hostnamectl hostname --static REMOTE_HOSTNAME

cd /home/igncp
sudo apt-get update

# This disables the prompt to restart services after every install
export DEBIAN_FRONTEND=noninteractive
sudo sed "s|#\$nrconf{restart} = 'i';|\$nrconf{restart} = 'a';|" -i /etc/needrestart/needrestart.conf

rm -rf ~/.check-files
bash ~/project/provision/provision.sh
# Set up the timezone with the bash alias

sudo fallocate -l "SWAP_NUM"G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo sh -c "echo '/swapfile none swap sw 0 0' >> /etc/fstab"

sudo chsh igncp -s /usr/bin/zsh

# Forbids using 'sudo su', which can cause problems in some applications
sudo sed 's|^root:.*|root:x:0:0:root:/root:/sbin/nologin|' -i /etc/passwd

## This should be a temporal fix until there is more space in the volume
## It requires "yarn"
# sudo mkdir /external ; mkdir /home/igncp/external ; sudo chown -R igncp:igncp /external
# sudo mount --bind /external /home/igncp/external
# yarn config set cache-folder /home/igncp/external/yarn
EOF

scp -P PORT -i SSH_KEY_PATH /tmp/prepare_igncp.sh \
  igncp@REMOTE_HOSTNAME:/tmp/prepare_igncp.sh

rm /tmp/prepare_igncp.sh

ssh -t -p PORT -i SSH_KEY_PATH igncp@REMOTE_HOSTNAME \
  'sudo echo "Prepare igncp" ; bash /tmp/prepare_igncp.sh'

# `remove_droplet.sh`

# With digital ocean
# Replace:
# - DROPLET_IMPORTANT
# - DROPLET_NAME

set -e

DROPLET_ID=$(doctl compute droplet list | grep -v DROPLET_IMPORTANT | grep DROPLET_NAME | awk '{print $1}')
doctl compute droplet delete --force $DROPLET_ID
echo "Droplet DROPLET_NAME deleted"

# `doctl_logout.sh`

set -e
doctl auth remove --context default
echo "doctl logout"
