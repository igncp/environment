#!/usr/bin/env bash

set -e

provision_setup_linux_gui() {
  if [ ! -f "$PROVISION_CONFIG"/gui ]; then
    return
  fi

  if [ -f "$PROVISION_CONFIG"/gui-xorg ]; then
    if [ ! -f ~/.check-files/gui-xorg ]; then
      if [ ! -f "$PROVISION_CONFIG"/wayland ]; then
        echo "Installing Xorg"
        install_system_package_os "xorg"
        install_system_package_os "xorg-xinit" startx

        touch ~/.check-files/gui-xorg
      fi
    fi

    cat >>~/.shell_aliases <<EOF
alias XClipCopy='xclip -selection clipboard' # usage: echo foo | XClipCopy
alias XClipPaste='xclip -selection clipboard -o'
EOF

    if ! type crond >/dev/null 2>&1; then
      if [ "$IS_ARCH" == "1" ]; then
        install_system_package_os cronie crond
        sudo systemctl enable --now cronie
      fi
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
EOF

  if type i3 >/dev/null 2>&1; then
    if [ -d ~/.config/i3 ]; then
      cp ~/development/environment/src/config-files/i3-config ~/.config/i3/config
    fi

    bash $HOME/development/environment/src/config-files/i3blocks.sh
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
}
