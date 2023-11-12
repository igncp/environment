#!/usr/bin/env bash

set -e

provision_setup_env() {
  PROVISION_CONFIG=~/development/environment/project/.config

  IS_LINUX=$(uname -a | grep -c Linux || true)
  IS_MAC=""
  if [[ $OSTYPE == 'darwin'* ]]; then
    IS_MAC="1"
  fi

  if [ ! -d "$PROVISION_CONFIG" ]; then
    echo "Please create a .config file in $PROVISION_CONFIG"
    exit 1
  fi

  if [ ! -f "$PROVISION_CONFIG"/theme ]; then
    echo 'dark' >"$PROVISION_CONFIG"/theme
  fi

  THEME=$(cat "$PROVISION_CONFIG"/theme | tr -d '\n')

  IS_DEBIAN=$(uname -a | grep -c Debian || uname -a | grep -c Ubuntu || true)
  IS_NIXOS=$(uname -a | grep -c NixOS || true)
  IS_ARCH="0"

  if [ -f /etc/os-release ] && [ -n "$(cat /etc/os-release | grep 'Arch Linux' || true)" ]; then
    IS_ARCH="1"
  fi

  mkdir -p ~/.check-files

  # This assumes now that the OS is using `nix`
  install_system_package() {
    PACKAGE=$1
    BIN_CHECK=${2:-$PACKAGE}

    if ! type "$BIN_CHECK" >/dev/null 2>&1; then
      echo "Requesting to install: $PACKAGE"
    fi
  }

  install_system_package_os() {
    PACKAGE=$1
    BIN_CHECK=${2:-$PACKAGE}

    if ! type "$BIN_CHECK" >/dev/null 2>&1; then
      if [ "$IS_LINUX" == "1" ]; then
        if [ "$IS_DEBIAN" == "1" ]; then
          sudo apt install -y "$PACKAGE"
        elif [ "$IS_ARCH" = "1" ]; then
          sudo pacman -S --noconfirm "$PACKAGE"
        else
          echo "Unknown linux distribution: $PACKAGE"
          exit 1
        fi
      elif [ "$IS_MAC" = "1" ]; then
        brew install "$PACKAGE"
      else
        echo "Unknown OS"
        exit 1
      fi
    fi
  }

  provision_append_json() {
    FILENAME=$1
    CONTENT=$2
    sed 's|^}$|,|' -i "$FILENAME"
    echo "$CONTENT" >>"$FILENAME"
    echo "}" >>"$FILENAME"
  }

  mkdir -p ~/development/environment/project
  cat >~/development/environment/project/backup.sh <<"EOF"
# Don't run this script directly, it is used by `src/scripts/backup.sh`
set -x
rsync -rh --delete /etc/hosts "$BACKUP_PATH/hosts"
rsync -rh --delete ~/development/environment/ "$BACKUP_PATH/environment/"
# Examples, uncomment via cusom.sh to apply:
# rsync -rh --delete ~/Downloads/ "$BACKUP_PATH/Downloads/"
# rsync -rh --delete ~/Document/ "$BACKUP_PATH/Documents/"
# rsync -rh --delete ~/.ssh/ "$BACKUP_PATH/ssh/"
EOF
}
