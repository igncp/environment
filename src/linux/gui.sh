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
}
