#!/usr/bin/env bash

set -euo pipefail

. src/linux/gui/dunst.sh
. src/linux/gui/i3.sh
. src/linux/gui/lxde.sh
. src/linux/gui/surface.sh
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
      if [ ! -f "$PROVISION_CONFIG"/gui-wayland ]; then
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
      (cd ~/rofi_theme && git reset --hard 459eee3) # @upgrade
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
alias WallpaperPrintCurrent="cat ~/.fehbg | grep --color=never -o '\/home\/.*jpg'"
EOF

  if type hyprctl >/dev/null 2>&1; then
    mkdir -p ~/.config/hypr
    # https://github.com/hyprwm/Hyprland/tree/main/example
    cp \
      ~/development/environment/src/config-files/hyprland.conf \
      /tmp/hyprland.conf

    if [ "$IS_SURFACE" == "1" ]; then
      sed -i 's|monitor=,preferred,auto,auto|monitor=,preferred,auto,1.6|' /tmp/hyprland.conf
    fi

    mv /tmp/hyprland.conf ~/.config/hypr/hyprland.conf

    if [ ! -f ~/.config/hypr/hyprpaper.conf ]; then
      touch ~/.config/hypr/hyprpaper.conf
    fi

    if type waybar >/dev/null 2>&1; then
      mkdir -p ~/.config/waybar
      cp \
        ~/development/environment/src/config-files/waybar.jsonc \
        ~/.config/waybar/config.jsonc
    fi
  fi

  if type ibus >/dev/null 2>&1; then
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
  fi

  if type fcitx5 >/dev/null 2>&1; then
    if [ -d ~/.local/share/fcitx5/rime/build ] &&
      [ ! -f ~/.local/share/fcitx5/rime/build/jyut6ping3.dict.yaml ]; then
      mkdir -p ~/misc
      rm -rf ~/misc/plum
      git clone https://github.com/rime/plum.git ~/misc/plum
      cd ~/misc/plum
      ./rime-install rime-cantonese
      cp ~/misc/plum/package/rime/cantonese/* ~/.local/share/fcitx5/rime/build
    fi

    if [ -f ~/.local/share/fcitx5/rime/build/default.yaml ]; then
      if [ -z "$(grep jyut6ping3 ~/.local/share/fcitx5/rime/build/default.yaml || true)" ]; then
        cat ~/.local/share/fcitx5/rime/build/default.yaml |
          yq '.schema_list += [{ "schema": "jyut6ping3" }]' -y |
          sponge ~/.local/share/fcitx5/rime/build/default.yaml
      fi
    fi
  fi

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
    "$HOME/development/environment/src/scripts/misc/wallpaper_update.sh" 'wallpaper-update' 'Wallpaper Update'

  if [ -d ~/.screenlayout ] && type xrandr >/dev/null 2>&1; then
    DESKTOP_PROFILES=$(find ~/.screenlayout -type f -name '*.sh' | xargs -I {} basename {} .sh)

    for PROFILE in $DESKTOP_PROFILES; do
      add_desktop_common \
        "bash ~/.screenlayout/$PROFILE.sh" "xrandr_profile_$PROFILE" "XRandr Profile $PROFILE"
    done
  fi

  setup_gui_vnc
  provision_setup_gui_surface
  setup_gui_i3
  setup_gui_lxde
  setup_gui_dunst
}
