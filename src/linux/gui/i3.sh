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

  if [ "$IS_DEBIAN" = "1" ]; then
    echo 'export GTK_THEME=Adwaita:dark' >$HOME/.xsession
    echo 'export GTK_IM_MODULE="ibus";' >>$HOME/.xsession
    echo 'export QT_IM_MODULE="ibus"' >>$HOME/.xsession
    echo 'export XMODIFIERS="@im=ibus"' >>$HOME/.xsession
    echo 'exec $HOME/.nix-profile/bin/i3' >>$HOME/.xsession

    # i3lock Needs be installed in the system
    if ! type i3lock >/dev/null 2>&1; then
      install_system_package_os i3lock
    fi

    # 系統範圍 systemd 服務用於在自動暫停之前鎖定螢幕（例如蓋上筆記型電腦或閒置逾時）
    # i3lock 需要 root 權限進行 PAM 驗證，但必須作為用戶運行以訪問 X 顯示
    if [ ! -f /etc/systemd/system/i3lock.service ]; then
      sed "s/__USERNAME__/$USER/g" $HOME/development/environment/src/linux/gui/i3lock-system.service |
        sudo tee /etc/systemd/system/i3lock.service >/dev/null
      sudo systemctl daemon-reload
      sudo systemctl enable i3lock.service
    fi
  fi

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
