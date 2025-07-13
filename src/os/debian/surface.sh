#!/usr/bin/env bash

set -euo pipefail

# 安裝
# - 進入 BIOS ：關機，按住調高音量按鈕，按住電源按鈕
# - 正常安裝先
#   - 唔好安裝任何 GUI 嚟令佢快啲，而係用 LVM 嘅磁碟加密，同埋安裝 SSH
# - https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup#debian--ubuntu
# - 手動，安裝後（透過 SSH ）
#
# su -
# apt install -y gpg sudo zsh gcc
# usermod -a -G sudo igncp
# chsh -s /usr/bin/zsh igncp
# wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc |
#   gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/linux-surface.gpg
# echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" |
#   tee /etc/apt/sources.list.d/linux-surface.list
# apt update
# apt install -y linux-image-surface linux-headers-surface libwacom-surface iptsd
# apt install -y linux-surface-secureboot-mok # For secure boot
#  # 修正新核心嘅 WIFI: https://github.com/linux-surface/linux-surface/issues/1636#issuecomment-2558442934
# update-grub
# systemctl disable ssh # Only start it manually
# # 當用 LXDE 嗰陣，佢修正咗鍵盤入面嘅問題，即係打咗幾個鍵之後佢會不斷斷線
# apt install -y lightdm lxde-core
# dpkg-reconfigure lightdm

provision_setup_os_debian_surface() {
  if [ "$IS_SURFACE" != "1" ]; then
    return
  fi

  if [ ! -f ~/.check-files/nerd-fonts ]; then
    mkdir -p ~/.fonts
    (cd ~/.fonts && wget https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Monofur/Regular/MonofurNerdFontMono-Regular.ttf)
    fc-cache -f -v || true
    touch ~/.check-files/nerd-fonts
  fi

  install_system_package_os keepass2
  install_system_package_os nextcloud-desktop nextcloud
  install_system_package_os vlc
  install_system_package_os lxappearance
  install_system_package_os chromium

  if ! type ghostty >/dev/null; then
    echo "Ghostty 未安裝，跟住呢個去 Debian 安裝佢"
    echo https://mansoorbarri.com/ghostty-is-here/
    echo "記得用乾淨嘅 bash ，例如用 BashClean 嘅別名"
    echo "你可能要更新「 * . desktop」檔案先可以用「 Exec 」入面嘅完整二進制檔案"
  fi

  # For ghostty
  if [ ! -f ~/.check-files/adwaita ]; then
    sudo apt install -y libadwaita-1-0
    touch ~/.check-files/adwaita
  fi

  # Ubuntu:
  # # 可以同 hwdb 換鍵:
  # # https://askubuntu.com/questions/1374276/swap-some-keyboard-keys
  # # 例子為: `/etc/udev/hwdb.d/99-keyboard.hwdb`
  # # evdev:name:Microsoft Surface Keyboard:*
  # #  KEYBOARD_KEY_70064=grave
  # # 要應用個效果: `sudo systemd-hwdb update ; sudo udevadm trigger`

  # # 隱藏桌面圖示:
  # # `sudo apt install gnome-shell-extension-prefs`
  # # 打開擴充程式應用程式

  # 為咗相機:
  # https://libcamera.org/getting-started.html
  if [ ! -f ~/.check-files/libcamera ] && [ -f "$PROVISION_CONFIG"/libcamera ]; then
    sudo apt install \
      build-essential meson ninja-build pkg-config libgnutls28-dev openssl \
      python3-pip python3-yaml python3-ply python3-jinja2 \
      qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 qttools5-dev-tools \
      libtiff-dev libevent-dev libyaml-dev \
      gstreamer1.0-tools libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev

    (
      cd ~ && rm -rf libcamera &&
        git clone https://git.libcamera.org/libcamera/libcamera.git &&
        cd libcamera &&
        meson build -Dpipelines=uvcvideo,vimc,ipu3 -Dipas=vimc,ipu3 -Dprefix=/usr -Dgstreamer=enabled -Dv4l2=true -Dbuildtype=release &&
        ninja -C build &&
        sudo ninja -C build install &&
        rm -rf ~/libcamera
    )

    touch ~/.check-files/libcamera
  fi
}
