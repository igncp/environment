#!/usr/bin/env bash

set -e

setup_gui_vnc() {
  # 用嚟做新嘅顯示器
  if [ -f "$PROVISION_CONFIG/tightvnc" ]; then
    if [ "$IS_DEBIAN" != "1" ]; then
      echo "tightvnc is only available for Debian"
      exit 1
    fi

    if [ ! -f ~/.check-files/gui-vnc ]; then
      sudo apt install -y tightvncserver dbus-x11
    fi

    # 故意唔啟用佢，所以佢只係手動啟動
    if [ ! -S /home/igncp/.config/systemd/user/tightvnc.service ]; then
      systemctl --user link /home/igncp/.config/systemd/user/tightvnc.service
      systemctl --user daemon-reload
    fi
  fi

  # 用喺同一個顯示器
  if [ -f "$PROVISION_CONFIG/x11vnc" ]; then
    if [ "$IS_DEBIAN" != "1" ]; then
      echo "tightvnc is only available for Debian"
      exit 1
    fi

    if [ ! -f ~/.check-files/gui-vnc ]; then
      sudo apt install -y x11vnc
    fi

    # 故意唔啟用佢，所以佢只係手動啟動
    if [ ! -S /home/igncp/.config/systemd/user/x11vnc.service ]; then
      systemctl --user link /home/igncp/.config/systemd/user/x11vnc.service
      systemctl --user daemon-reload
    fi

    # Set password
    # x11vnc -storepasswd
  fi
}
