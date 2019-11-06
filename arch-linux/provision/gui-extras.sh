# gui-extras START

# alacritty
  install_pacman_package alacritty
  check_file_exists /project/provision/alacritty.yml
  mkdir -p ~/.config/alacritty
  cp /project/provision/i3-config ~/.config/alacritty/alacritty.yml
  cat >> ~/.bash_aliases <<"EOF"
alias Alacritty='LANG=en_hk alacritty & exit'
alias ModifyAlacritty='$EDITOR /project/provision/alacritty.yml;
    cp /project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml; echo "alacritty.yml copied"'
EOF

# eclim
  if [ ! -f ~/.check-files/eclim ]; then
    cd ~
    wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
    java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
    touch ~/.check-files/eclim
  fi

# vscode
  if ! type code > /dev/null 2>&1 ; then
    if [ -f /home/igncp/Downloads/vscode.tar.gz ]; then
      (cd /home/igncp/Downloads \
        && sudo rm -rf /usr/bin/code /opt/visual-studio-code /home/igncp/Downloads/VSCode-* \
        && tar xf vscode.tar.gz \
        && sudo mv VSCode-* /opt/visual-studio-code \
        && sudo ln -s /opt/visual-studio-code/bin/code /usr/bin/code \
        && rm -rf vscode.tar.gz)
    else
      echo "Not installing VS Code because the file '~/Downloads/vscode.tar.gz' is missing."
      echo "  https://code.visualstudio.com/#alt-downloads"
    fi
  fi

  mkdir -p /home/igncp/.config/Code/User
  cp /project/provision/vscode-settings.json /home/igncp/.config/Code/User/settings.json

# Automatic X server
  cat >> ~/.bashrc <<"EOF"
if ! xhost >& /dev/null && [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  exec startx
fi
EOF

# Keys handling (for host)
  # For Brightness: update intel_backlight with the correct card
  sudo chown igncp /sys/class/backlight/intel_backlight/brightness
  cat > /home/igncp/change_brightness.sh <<"EOF"
  echo $(("$(cat /sys/class/backlight/intel_backlight/brightness)" + "$1")) | tee /sys/class/backlight/intel_backlight/brightness
EOF
  install_pacman_package xbindkeys
  cat > ~/.xbindkeysrc <<"EOF"
# Docs
# - https://wiki.archlinux.org/index.php/Xbindkeys#Installation
# - https://wiki.archlinux.org/index.php/Backlight#xbacklight
# refresh:
# - stop (all) xbindkeys process(es)
# - run: xbindkeys
# get key name: xbindkeys --multikey
# generate default config: xbindkeys -d > ~/.xbindkeysrc

# specify a mouse button
"amixer set Master 10%-"
  XF86AudioLowerVolume

"amixer set Master 10%+"
  XF86AudioRaiseVolume

# https://unix.stackexchange.com/a/385116
"sh /home/igncp/change_brightness.sh 3000"
  XF86MonBrightnessUp

"sh /home/igncp/change_brightness.sh -3000"
  XF86MonBrightnessDown
EOF

# conky (for host)
  install_pacman_package conky
  cat >> ~/.bash_aliases <<"EOF"
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

# gui-extras END
