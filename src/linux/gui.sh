#!/usr/bin/env bash

set -e

. src/linux/gui/vnc.sh

provision_setup_linux_gui() {
  cat >>~/.shell_aliases <<EOF
if type xclip >/dev/null 2>&1; then
  alias XClipCopy='xclip -selection clipboard' # usage: echo foo | XClipCopy
  alias XClipPaste='xclip -selection clipboard -o'
fi
EOF

  if [ ! -f "$PROVISION_CONFIG"/gui ]; then
    return
  fi

  mkdir -p ~/.scripts && cat >~/.scripts/choose_terminal.sh <<'EOF'
if [ -f ~/.local/bin/ghostty ]; then
  ~/.local/bin/ghostty
elif [ -s /run/current-system/sw/bin/ghostty ]; then
  /run/current-system/sw/bin/ghostty
else
  /run/current-system/sw/bin/terminator
fi
EOF
  chmod +x ~/.scripts/choose_terminal.sh

  if [ -f "$PROVISION_CONFIG"/gui-xorg ]; then
    if [ ! -f ~/.check-files/gui-xorg ]; then
      if [ ! -f "$PROVISION_CONFIG"/wayland ]; then
        echo "Installing Xorg"
        install_system_package_os "xorg"
        install_system_package_os "xorg-xinit" startx

        touch ~/.check-files/gui-xorg
      fi
    fi

    if ! type crond >/dev/null 2>&1; then
      if [ "$IS_ARCH" == "1" ]; then
        install_system_package_os cronie crond
        sudo systemctl enable --now cronie
      fi
    fi
  fi

  if type rofi >/dev/null 2>&1; then
    mkdir -p ~/.config/rofi
    if [ ! -f ~/.config/rofi/config.rasi ]; then
      rm -rf ~/rofi_theme
      git clone https://github.com/dracula/rofi ~/rofi_theme
      cp ~/rofi_theme/theme/config1.rasi ~/.config/rofi/config.rasi
      rm -rf ~/rofi_theme
      sed -i '/font: /d' ~/.config/rofi/config.rasi
    fi
  fi

  # GTK
  #   https://www.gnome-look.org/browse/ord/rating/
  #   Can run: lxappearance # including inside Rofi
  #   Themes:
  #   If downloaded and `.tar.xz` file, uncompress with `tar -xf ...`
  #   Move the directory inside `~/.themes/`
  #   Icons: Don't uncompress the file, import it directly from lxappearance
  #   Currently using:
  #   - Cursors: Comix (use the opaque) - https://www.gnome-look.org/p/999996/
  #   - Icons: Flatery - https://www.gnome-look.org/s/Gnome/p/1332404
  #   - Theme: Prof-Gnome-theme - https://www.gnome-look.org/p/1334194/
  #   - Grub: Tela - https://www.gnome-look.org/p/1307852/

  # Keyboard Setup (not only Arch): https://wiki.archlinux.org/index.php/X_keyboard_extension

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
alias WallpaperPrintCurrent="cat ~/.fehbg | grep --color=never -o '\/home\/.*jpg'"
EOF

  if type i3 >/dev/null 2>&1; then
    if [ -d ~/.config/i3 ]; then
      if [ ! -f $HOME/.local/bin/ghostty ] && [ "$IS_NIXOS" != "1" ]; then
        echo "Not copying the i3 config because ghostty is not in the expected path"
      else
        cp ~/development/environment/src/config-files/i3-config ~/.config/i3/config
      fi
    fi

    bash $HOME/development/environment/src/config-files/i3blocks.sh

    if [ -z "$(fc-list | grep '\bnoto\b' || true)" ]; then
      install_system_package_os fonts-noto
    fi

    install_system_package_os rofi
    install_system_package_os i3blocks
  fi

  cat >~/.scripts/set_background.sh <<'EOF'
feh --bg-fill "$1"
cat ~/.fehbg | grep --color=never -o '/home/.*jpg' | sed 's|^|Image: |'
EOF

  cat >~/.scripts/wallpaper_update.sh <<'EOF'
if [ -d ~/.config/variety/Downloaded ]; then
  find ~/.config/variety/Downloaded -type f -name *.jpg | shuf -n 1 | xargs -I {{}} bash ~/.scripts/set_background.sh {{}}
fi
EOF
  chmod +x ~/.scripts/wallpaper_update.sh

  if [ ! -f ~/.config/ibus/rime/default.yaml ]; then
    mkdir -p ~/misc ~/.config/ibus/rime
    rm -rf ~/misc/plum
    git clone https://github.com/rime/plum.git ~/misc/plum
    cd ~/misc/plum
    ./rime-install rime-cantonese
    ./rime-install gkovacs/rime-japanese
  fi

  cp ~/development/environment/src/config-files/rime-config.yaml \
    ~/.config/ibus/rime/default.yaml

  # 例如:
  # add_desktop_common '/usr/bin/xdg-open /foo/bar.odt' 'open_foo_bar' 'Open Foo Bar'
  # 其他命令: google-chrome-stable https://foo.com
  add_desktop_common() {
    CMD="$1"
    FILE_NAME="$2"
    NAME="$3"
    echo "$CMD" >~/.scripts/"$FILE_NAME".sh
    chmod +x ~/.scripts/"$FILE_NAME".sh
    printf "[Desktop Entry]\nName=$NAME\nExec=$HOME/.scripts/$FILE_NAME.sh\nType=Application" >/tmp/"$FILE_NAME".desktop
    if [ "$IS_NIXOS" = "1" ]; then
      mkdir -p ~/.local/state/nix/profiles/profile/share/applications
      sudo mv /tmp/"$FILE_NAME".desktop ~/.local/state/nix/profiles/profile/share/applications
    else
      sudo mv /tmp/"$FILE_NAME".desktop /usr/share/applications/
    fi
  }

  add_desktop_common \
    "$HOME/.scripts/wallpaper_update.sh" 'wallpaper-update' 'Wallpaper Update'

  if [ -d ~/.screenlayout ] && type xrandr >/dev/null 2>&1; then
    DESKTOP_PROFILES=$(find ~/.screenlayout -type f -name '*.sh' | xargs -I {} basename {} .sh)

    for PROFILE in $DESKTOP_PROFILES; do
      add_desktop_common \
        "bash ~/.screenlayout/$PROFILE.sh" "xrandr_profile_$PROFILE" "XRandr Profile $PROFILE"
    done
  fi

  setup_gui_vnc
}
