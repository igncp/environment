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
  sudo grep -qF -- "LoadModule php7_module modules/libphp7.so" /etc/httpd/conf/httpd.conf || \
    echo "LoadModule php7_module modules/libphp7.so" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null
  sudo grep -qF -- "AddHandler php7-script .php" /etc/httpd/conf/httpd.conf || \
    echo "AddHandler php7-script .php" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null
  sudo grep -qF -- "Include conf/extra/php7_module.conf" /etc/httpd/conf/httpd.conf || \
    echo "Include conf/extra/php7_module.conf" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null

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
if ! type cockpit-bridge > /dev/null 2>&1 ; then
  sudo pacman -S --noconfirm cockpit packagekit
  sudo systemctl enable --now cockpit.socket
fi

# conky
  install_system_package conky
  cat >> ~/.shell_aliases <<"EOF"
alias Conky='conky --config=/home/igncp/.conky.conf & exit'
EOF
  cat > ~/.conky.conf <<"EOF"
conky.config = {
    alignment = 'top_left',
    background = false,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'DejaVu Sans Mono:size=20',
    gap_x = 60,
    gap_y = 60,
    minimum_height = 720,
    minimum_width = 1280,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = override,
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
}

conky.text = [[
${color grey}$color ${scroll 1920 $sysname $nodename $kernel $machine}
$hr
${color grey}${uid_name 1000}
${color grey}Uptime:$color $uptime
${voffset 10}
${font Open Sans Light:pixelsize=80}Battery: ${battery_percent BAT0}%${font}
${battery_bar}
${voffset 10}
${color grey}Frequency (in MHz):$color $freq
${color grey}Frequency (in GHz):$color $freq_g
${color grey}RAM Usage:$color $mem/$memmax - $memperc% ${membar 4}
${color grey}Swap Usage:$color $swap/$swapmax - $swapperc% ${swapbar 4}
${color grey}CPU Usage:$color $cpu% ${cpubar 4}
${color grey}Processes:$color $processes  ${color grey}Running:$color $running_processes
$hr
${color grey}File systems:
 / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
${color grey}Networking:
Up:$color ${upspeed} ${color grey} - Down:$color ${downspeed}
$hr
${font Open Sans Light:pixelsize=60}${time %H:%M:%S} - ${time %d.%m.%Y}${font}
]]
EOF
  cat > ~/.conky.sh <<"EOF"
#!/usr/bin/env bash

CONKY_ID="$(ps -aux | grep conky | grep -v grep | grep '\.conky\.sh' -v | awk '{ print $2 }')"
echo "$CONKY_ID"
if [ ! -z "$CONKY_ID" ]; then
  kill "$CONKY_ID"
fi
/usr/bin/conky --config=/home/igncp/.conky.conf & exit
EOF
  chmod +x ~/.conky.sh

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
cat > "$HOME"/.config/redshift/redshift.conf <<"EOF"
[redshift]
; There is an issue with 'geoclue2' provider
location-provider=manual

; Madrid
[manual]
lat=40.416775
lon=-3.703790
EOF

# arch-misc END
