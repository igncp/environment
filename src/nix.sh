#!/usr/bin/env bash

set -euo pipefail

provision_setup_nix() {
  if [ "$IS_WINDOWS" = "1" ]; then
    return
  fi

  mkdir -p ~/.config/nix
  mkdir -p ~/.pip

  if ! type nix >/dev/null 2>&1; then
    mkdir -p ~/.local/state/home-manager/profiles

    # 如果重新安裝 Nix，則需要此操作
    sudo rm -rf /etc/bash.bashrc*
    sudo rm -rf /etc/bashrc*
    sudo rm -rf /etc/zshrc*

    if [ "$IS_MAC" ]; then
      sh <(curl -L https://nixos.org/nix/install)
      sudo mkdir -p /nix/var/nix/profiles/per-user/$USER
      sudo chown $USER /nix/var/nix/profiles/per-user/$USER
    else
      if ! type curl >/dev/null 2>&1; then
        if [ "$IS_DEBIAN" == "1" ]; then
          # 使用者可能還不在`sudo`群組中，可以添加
          # `/usr/sbin/usermod -a -G sudo $USER`
          su -c 'apt-get update && apt-get install -y curl'
          su -c "mkdir -p /nix/var/nix/profiles/per-user/$USER"
          su -c "chown $USER /nix/var/nix/profiles/per-user/$USER"
        fi
      fi

      if [ -f /run/systemd/resolve/stub-resolv.conf ]; then
        sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
      fi

      echo "安裝 nix"
      sh <(curl -L https://nixos.org/nix/install) --daemon --yes
    fi
  fi

  if [ "$IS_LINUX" = "1" ]; then
    if type sudo >/dev/null 2>&1; then
      ROOT_HOME=$(eval echo "~root")
      cat >/tmp/.root_bashrc <<"EOF"
export PATH="$PATH":/home/_USER_/.nix-profile/bin
export EDITOR="nvim"
alias ll='ls -lah'
alias n='nvim'
EOF
      sed -i "s|_USER_|$USER|g" /tmp/.root_bashrc
      sudo bash -c "cat /tmp/.root_bashrc >> $ROOT_HOME/.bashrc"
      rm /tmp/.root_bashrc
    fi
  fi

  cat >~/.config/nix/nix.conf <<"EOF"
experimental-features = nix-command flakes
EOF

  add_vscode_extension bbenoist.nix

  if [ "$IS_NIXOS" == "1" ]; then
    if ! type tmux >/dev/null 2>&1; then
      echo "您需要安裝軟體包"
      echo "在繼續之前運行 RebuildNix"
      exit 1
    fi
    if [ -f /etc/nixos/configuration.nix ]; then
      sudo alejandra -q /etc/nixos/configuration.nix
    fi
    if [ -f /etc/nixos/hardware-configuration.nix ]; then
      sudo alejandra -q /etc/nixos/hardware-configuration.nix
    fi
  else
    if ! type home-manager >/dev/null 2>&1 && [ ! -f "$PROVISION_CONFIG"/no-home-manager ]; then
      # The user should be in the sudoers file for this to work
      sudo mkdir -p /nix/var/nix/profiles/per-user/$USER
      sudo mkdir -p /nix/var/nix/db/
      sudo mkdir -p /nix/var/nix/temproots/

      sudo chown -R $USER /nix/var/nix/profiles/per-user
      sudo chown -R $USER /nix/var/nix/gcroots/per-user || true
      sudo chown -R $USER /nix/var/nix/db/
      sudo chown -R $USER /nix/var/nix/temproots/

      # 在 docker 中運行
      if [ -z "$(ps aux | grep nix-daemon | grep -v grep || true)" ]; then
        sudo /nix/var/nix/profiles/default/bin/nix-daemon 2>&1 >/dev/null &
      else
        echo "Nix 守護程式已在執行"
      fi

      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      sleep 10
      nix-shell -p git home-manager --run "bash -c '. $HOME/development/environment/src/config-files/.shell_aliases.sh && RebuildNix'"
    fi
  fi

  if [ "$IS_NIXOS" != "1" ]; then
    cat >/tmp/load_nix.sh <<"EOF"
if [ -z "$PROVISION_NIX_LOADED" ]; then
  export PROVISION_NIX_LOADED=1
  export PATH="$HOME/.nix-profile/bin:$PATH"

  if [ -f "~/.nix-profile/etc/profile.d/nix.sh" ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
  fi

  if [ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
  fi

  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi
EOF

    # 盡快加載 nix （即使多次）
    cat /tmp/load_nix.sh >>~/.zshrc
    cat /tmp/load_nix.sh >>~/.shellrc
    cat /tmp/load_nix.sh >>~/.bashrc

    touch ~/.zshenv
    if [ -z "$(grep nix-profile ~/.zshenv || true)" ]; then
      cat /tmp/load_nix.sh >>~/.zshenv
    fi
  fi

  cat >>~/.zshrc <<"EOF"
if type direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
  export DIRENV_LOG_FORMAT=""
fi
EOF

  if type git >/dev/null 2>&1 && [ ! -d ~/misc/nixpkgs ]; then
    mkdir -p ~/misc
    git clone https://github.com/NixOS/nixpkgs.git --depth 1 ~/misc/nixpkgs
  fi

  # 要在 cron 腳本中使用 `nix`，可以將其新增至 crontab 中
  # `PATH=/home/igncp/.nix-profile/bin`
}
