#!/usr/bin/env bash

set -e

mkdir -p ~/.config/nix

cat >~/.config/nix/nix.conf <<"EOF"
experimental-features = nix-command flakes
EOF

REAL_PASSWD=$(realpath /etc/passwd)
REAL_SHADOW=$(realpath /etc/shadow)
REAL_GROUP=$(realpath /etc/group)

rm -rf /etc/passwd /etc/shadow /etc/gshadow /etc/group

cp $REAL_PASSWD /etc/passwd
cp $REAL_SHADOW /etc/shadow
cp $REAL_GROUP /etc/group

echo 'sshd:x:33:33:::' >>/etc/passwd
echo 'igncp:x:1000:1000::/home/igncp:/bin/sh' >>/etc/passwd
echo 'igncp:!:::::::' >>/etc/shadow
echo 'sshd:x:33:' >>/etc/group
echo 'igncp:x:1000:' >>/etc/group

mkdir -p /var/empty
if [ ! -f /etc/ssh/sshd_config ]; then
  cat >/etc/ssh/sshd_config <<"EOF"
AuthorizedPrincipalsFile none
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
GatewayPorts no
KbdInteractiveAuthentication yes
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
LogLevel INFO
PasswordAuthentication no
PermitRootLogin yes
PrintMotd no
StrictModes yes
UseDns no
UsePAM yes
X11Forwarding no
Banner none
AddressFamily any
Port 22
AuthorizedKeysFile %h/.ssh/authorized_keys /etc/ssh/authorized_keys.d/%u
EOF
fi

mkdir -p /etc/pam.d
cat >/etc/pam.d/other <<"EOF"
#%PAM-1.0
auth        sufficient  pam_rootok.so
auth        required    pam_permit.so
account     required    pam_permit.so
account     required    pam_warn.so
session     required    pam_permit.so
password    required    pam_permit.so
EOF

mkdir -p /etc/sudoers.d
cat >/etc/sudoers <<"EOF"
root ALL=(ALL) ALL
igncp ALL=(ALL) NOPASSWD: ALL
EOF

if [ ! -d /home/igncp/.config ]; then
  mkdir -p /home/igncp
  chown -R igncp:igncp /home/igncp
  touch ~/.zshrc /home/igncp/.zshrc
  mkdir -p /home/igncp/development
  cp -r ~/.config /home/igncp/.config
  chown -R igncp:igncp /home/igncp/.zshrc /home/igncp/.config
fi

nix-shell -p shadow --run "usermod -a -G nixbld igncp"

if [ -d /home/igncp/development/environment/project ]; then
  mv /home/igncp/development/environment/project /home/igncp/env_project
fi
rm -rf /home/igncp/development/environment
cp -r /environment /home/igncp/development/environment
if [ -d /home/igncp/env_project ]; then
  rm -rf /home/igncp/development/environment/project
  mv /home/igncp/env_project /home/igncp/development/environment/project
fi
chown -R igncp:igncp /home/igncp/development
chown -R igncp:igncp /environment/project/.config

cat >/root/container_entry.sh <<"EOF"
if [ ! -d /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -A
fi
$(which sshd)
echo "SSH 伺服器開始咗..."
echo "執行呢個指令: ssh -tt -p 2022 -A root@localhost sh run_this_when_ssh.sh"
sleep 1000000
EOF

cat >/root/ssh_entry.sh <<"EOF"
cd /home/igncp/development/environment
chown -R root /nix
chown -R igncp /tmp
chmod u+s $(which sudo)
chmod u+s $(which sponge)
HOME=/home/igncp USER=igncp su --shell $(which zsh) --preserve-env - igncp || true
EOF

cat >/root/run_this_when_ssh.sh <<"EOF"
export PATH="$PATH:/root/.nix-profile/bin"
cd /root/environment
nix develop \
  --impure \
  .#dockerEnv \
  --command bash -c 'bash /root/ssh_entry.sh'
exit
EOF

cat >/etc/locale.conf <<"EOF"
LANG=zh_TW.UTF-8
LC_ALL=zh_TW.UTF-8
LANGUAGE=zh_TW.UTF-8
EOF

rm -rf /root/environment
cp -r /environment /root/environment
chown -R root /root/environment || true
cd /root/environment

nix develop \
  --impure \
  .#dockerEnv \
  --command bash -c 'bash /root/container_entry.sh'
