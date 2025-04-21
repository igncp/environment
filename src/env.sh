#!/usr/bin/env bash

set -e

provision_setup_env() {
  IS_LINUX=$(uname -a | grep -c Linux || true)
  IS_MAC=""
  if [[ $OSTYPE == 'darwin'* ]]; then
    IS_MAC="1"
  fi

  mkdir -p "$PROVISION_CONFIG"

  if [ ! -f "$PROVISION_CONFIG"/theme ]; then
    echo 'dark' >"$PROVISION_CONFIG"/theme
  fi

  THEME=$(cat "$PROVISION_CONFIG"/theme | tr -d '\n')

  IS_WINDOWS=$(uname -a | grep -c MINGW64 | grep 1 || true)
  IS_DEBIAN=$(uname -a | grep -c Debian | grep 1 || uname -a | grep -c Ubuntu | grep 1 || true)
  IS_UBUNTU=$(uname -a | grep -c Ubuntu | grep 1 || true)
  IS_NIXOS=$(uname -a | grep -c NixOS || true)
  IS_ARCH="0"

  if [ -f /etc/os-release ]; then
    # 用於 MS Surface
    IS_DEBIAN="$(cat /etc/os-release | grep '^NAME' | grep -c Debian | grep 1 || true)"
  fi

  IS_SURFACE="$(uname -a | grep -c 'Linux surface' || true)"
  if [ -f "$PROVISION_CONFIG"/surface ]; then
    IS_SURFACE="1"
  fi

  if [ "$IS_LINUX" = "1" ] && [ ! -f "$PROVISION_CONFIG"/skip-root-bashrc ]; then
    if type sudo >/dev/null 2>&1; then
      ROOT_HOME=$(eval echo "~root")
      sudo bash -c 'echo "" > ~/.bashrc'
    fi
  fi

  if [ -f /etc/os-release ] && [ -n "$(cat /etc/os-release | grep 'Arch Linux' || true)" ]; then
    IS_ARCH="1"
  fi

  mkdir -p ~/.check-files
  mkdir -p ~/.completions

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
        elif [ "IS_NIXOS" = "1" ]; then
          echo "請求安裝此軟體包: $PACKAGE"
        else
          echo "此軟體包遺失: $PACKAGE"
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

  cat >~/development/environment/project/backup.sh <<"EOF"
# Don't run this script directly, it is used by `src/scripts/backup.sh`
set -x
rsync -rh --delete /etc/hosts "$BACKUP_PATH/hosts"
rsync -rh --delete ~/development/environment/ "$BACKUP_PATH/environment/"
# 這些是範例，請取消註解 "~/development/environment/src/custom.sh" 檔案中的這些行以套用 :
# rsync -rh --delete ~/Downloads/ "$BACKUP_PATH/Downloads/"
# rsync -rh --delete ~/Document/ "$BACKUP_PATH/Documents/"
# rsync -rh --delete ~/.ssh/ "$BACKUP_PATH/ssh/"
EOF
}
