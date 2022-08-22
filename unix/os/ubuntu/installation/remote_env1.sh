#!/usr/bin/env bash

set -e
# set -x # Uncomment for debugging

# Create the environment
  # Check the region of the environment to be able to attach the respective volumes
  # After creation, copy the IP and update it in `/etc/hosts` and attach the volume

# * In the host:

# With digital ocean
  doctl compute droplet create \
    --image ubuntu-22-04-x64 \
    --size ... \
    --region ... \
    --volumes ... \
    --droplet-agent=false \
    --wait \
    sample-env
  # doctl compute size list | less -S
  # doctl compute region list | less -S
  # doctl compute volume list | less -S

ssh root@REMOTE_HOSTNAME

# * As `root`:

# To paste commands
printf '#!/usr/bin/env bash\nset -e\n\n' > /tmp/script.sh ; "${EDITOR:-vim}" "+normal G$" +startinsert /tmp/script.sh && sh /tmp/script.sh

ufw allow ssh
ufw default deny outgoing
ufw default deny incoming
ufw allow out to any port 80
ufw allow out to any port 443
ufw allow out to any port 53
ufw enable

echo 'umask 0077' >> /etc/profile

# If it is using a fresh volume, set it up first
  cfdisk /dev/sda # Create the `/dev/sda1` partition (and others if necessary)
  # At this point only add password # @TODO use a random key in an encrypted file for decryption later
  cryptsetup -y -v luksFormat /dev/sda1
  cryptsetup open /dev/sda1 cryptmain
  mkfs.ext4 /dev/mapper/cryptmain
  cryptsetup close cryptmain

echo 'igncp ALL=(ALL) ALL' >> /etc/sudoers

useradd -m igncp ; echo 'Password for igncp' ; passwd igncp
useradd -m init ; echo 'Password for init' ; passwd init

echo 'cryptsetup open /dev/sda1 cryptmain ; mount /dev/mapper/cryptmain /home/igncp' > /home/init/init.sh
chmod 701 /home/init/init.sh ; chown root:root /home/init/init.sh
echo 'init ALL=NOPASSWD:/home/init/init.sh' >> /etc/sudoers
echo 'init ALL=NOPASSWD:/usr/sbin/reboot' >> /etc/sudoers

chsh igncp -s /usr/bin/bash ; chsh init -s /usr/bin/bash

# * In the host:

# Use a key with a passphrase
ssh-copy-id -i ~/.ssh/USEDKEY igncp@REMOTE_HOSTNAME
ssh-copy-id -i ~/.ssh/USEDKEY init@REMOTE_HOSTNAME
ssh -i ~/.ssh/USEDKEY igncp@REMOTE_HOSTNAME

# * As `igncp`:

sudo rm -rf /tmp/script.sh
printf '#!/usr/bin/env bash\nset -e\n\n' > /tmp/script.sh ; "${EDITOR:-vim}" "+normal G$" +startinsert /tmp/script.sh && sh /tmp/script.sh

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
  # * From host: `rsync -e 'ssh -i ~/.ssh/USEDKEY' -rhv --delete ./ igncp@REMOTE_HOSTNAME:/home/igncp/environment`
  sh /home/igncp/environment/unix/os/ubuntu/installation/remote_env2.sh
  echo 'REMOTE_ENV' > ~/project/.config/ssh-notice
  sudo umount /home/igncp ; sudo cryptsetup close cryptmain
# If not the first time
  sudo rm -rf /home/igncp ; sudo mkdir -p /home/igncp ; sudo chown -R igncp:igncp /home/igncp

sudo cryptsetup open /dev/sda1 cryptmain ; sudo mount /dev/mapper/cryptmain /home/igncp

sudo hostnamectl hostname --static REMOTE_HOSTNAME

cd /home/igncp
sudo apt-get update
sudo sed 's|^root:.*|root:x:0:0:root:/root:/sbin/nologin|' -i /etc/passwd

# This disables the prompt to restart services after every install
export DEBIAN_FRONTEND=noninteractive
sudo sed "s|#\$nrconf{restart} = 'i';|\$nrconf{restart} = 'a';|" -i /etc/needrestart/needrestart.conf

rm -rf ~/.check-files
bash ~/project/provision/provision.sh
# Set up the timezone with the bash alias

# @TODO: https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-20-04/

# Once finished, delete the environment

# With digital ocean
  doctl compute droplet list | grep -v DROPLET_IMPORTANT | grep DROPLET_NAME | less -S
  doctl compute droplet delete DROPLET_ID
