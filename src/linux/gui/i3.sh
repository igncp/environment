#!/usr/bin/env bash

set -euo pipefail

setup_gui_i3() {
  if [ ! -f "$PROVISION_CONFIG"/gui-i3 ]; then
    return
  fi

  cat >>~/.shell_aliases <<'EOF'
if type i3 >/dev/null 2>&1; then
  I3VMSetup() {
    /usr/bin/VBoxClient-all;
    # 運行 $(xrandr) 查看可用的輸出和模式:
      # xrandr --output Virtual-1 --mode 1280x768
  }
  alias I3GBLayout='setxkbmap -layout gb'
  alias I3Reload='i3-msg reload'
  alias I3LogOut='i3-msg exit'
  alias I3DetectAppClass="xprop | grep WM_CLASS"
  alias I3DetectAppName="xprop | grep WM_NAME"
  alias I3Poweroff='systemctl poweroff'
  alias I3Start='startx'
  I3Configure() {
    $EDITOR -p ~/project/provision/i3-config ~/project/provision/i3blocks.sh
    provision.sh
  }
fi
EOF

  if type i3 >/dev/null 2>&1; then
    if [ -d ~/.config/i3 ]; then
      cp ~/development/environment/src/config-files/i3-config ~/.config/i3/config
    fi

    bash $HOME/development/environment/src/config-files/i3blocks.sh

    if [ -z "$(fc-list | grep '\bnoto\b' || true)" ]; then
      install_system_package_os fonts-noto
    fi

    install_system_package_os rofi
    install_system_package_os i3blocks
  fi
}

#     if !context.system.is_nixos() {
#         System::run_bash_command(
#             r###"
# cat > ~/i3lock.service <<"EOF"
# [Unit]
# Description=Lock screen before suspend
# Before=sleep.target

# [Service]
# User=_USER_
# Type=forking
# Environment=DISPLAY=:0
# ExecStart=/usr/bin/i3lock -c 000000

# [Install]
# WantedBy=sleep.target
# EOF
# sed -i "s|_USER_|$USER|g" ~/i3lock.service
# sudo mv ~/i3lock.service /etc/systemd/system/
# sudo systemctl enable --now i3lock.service
# "###,
#         );
#     }

#     // picom: can be disabled due performance
#     if !Config::has_config_file(&context.system, ) {
#         context.system.install_system_package("picom", None);
#         System::run_bash_command(
#             r###"
# cp ~/development/environment/src/config-files/picom.conf ~/.config/picom.conf
# echo 'exec --no-startup-id picom' >> ~/.config/i3/config # remove this line to disable if performance slow
# echo "alias PicomModify='$EDITOR ~/project/provision/picom.conf && cp ~/project/provision/picom.conf ~/.config/picom.conf'" >> ~/.shell_aliases
# "###,
#         );
#     }
# }
