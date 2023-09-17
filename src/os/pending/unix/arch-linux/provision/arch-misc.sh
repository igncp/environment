# @TODO
# arch-misc START

# php-apache
if [ ! -f ~/.check-files/php-apache ]; then
  echo "installing php-apache"
  sudo pacman -S --noconfirm php-apache
  # https://wiki.archlinux.org/index.php/Apache_HTTP_Server#PHP
  sudo sh -c "echo '<?php phpinfo(); ?>' > /srv/http/php.php"
  sudo systemctl restart httpd.service
  touch ~/.check-files/php-apache
fi
sudo grep -qF -- "LoadModule php7_module modules/libphp7.so" /etc/httpd/conf/httpd.conf ||
  echo "LoadModule php7_module modules/libphp7.so" | sudo tee -a /etc/httpd/conf/httpd.conf >/dev/null
sudo grep -qF -- "AddHandler php7-script .php" /etc/httpd/conf/httpd.conf ||
  echo "AddHandler php7-script .php" | sudo tee -a /etc/httpd/conf/httpd.conf >/dev/null
sudo grep -qF -- "Include conf/extra/php7_module.conf" /etc/httpd/conf/httpd.conf ||
  echo "Include conf/extra/php7_module.conf" | sudo tee -a /etc/httpd/conf/httpd.conf >/dev/null

# Enable multilib (32)
# sudo vim /etc/pacman.conf # Uncomment the 4 multilib libs
# sudo pacman -Sy

# kvm
# for guests: https://www.spice-space.org/download.html
# sudo virsh net-start default # when network not found
if [ ! -f ~/.check-files/kvm ]; then
  sudo pacman -S --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat
  sudo pacman -S --noconfirm ebtables iptables dmidecode
  yay -S --noconfirm libguestfs
  sudo sed -i 's|#unix_sock_group|unix_sock_group|' /etc/libvirt/libvirtd.conf
  sudo sed -i 's|#unix_sock_rw_perms|unix_sock_rw_perms|' /etc/libvirt/libvirtd.conf
  sudo usermod -a -G libvirt $(whoami)
  newgrp libvirt
  sudo systemctl enable --now libvirtd.service
  touch ~/.check-files/kvm
fi

# rust code coverage

# for code coverage
install_system_package llvm llvm-ar
install_from_aur lcov https://aur.archlinux.org/lcov.git

# system overview with web client
if ! type cockpit-bridge >/dev/null 2>&1; then
  sudo pacman -S --noconfirm cockpit packagekit
  sudo systemctl enable --now cockpit.socket
fi

# diff tool
install_with_yay git-delta delta

install_with_yay speedread-git speedread
# @TODO
# https://github.com/jeffkowalski/gritz
# @TODO
# https://github.com/nemanjan00/uniread

# reduce blue light at night
install_system_package redshift
sed -i '1i(sleep 5s && redshift-gtk 2>&1 > /dev/null) &' ~/.xinitrc
mkdir -p "$HOME"/.config/redshift
cat >"$HOME"/.config/redshift/redshift.conf <<"EOF"
[redshift]
; There is an issue with 'geoclue2' provider
location-provider=manual

; Madrid
[manual]
lat=40.416775
lon=-3.703790
EOF

# arch-misc END
