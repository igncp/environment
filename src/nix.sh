#!/usr/bin/env bash

set -e

provision_setup_nix() {
  mkdir -p ~/.config/nix
  mkdir -p ~/.pip

  if ! type nix >/dev/null 2>&1; then
    mkdir -p ~/.local/state/home-manager/profiles

    # 如果重新安裝 Nix，則需要此操作
    sudo rm -rf /etc/bash.bashrc*
    sudo rm -rf /etc/bashrc*
    sudo rm -rm /etc/zshrc*

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

  cat >~/.config/nix/nix.conf <<"EOF"
experimental-features = nix-command flakes
EOF

  if [ "$IS_NIXOS" == "1" ]; then
    if ! type tmux >/dev/null 2>&1; then
      echo "您需要安裝軟體包"
      echo "在繼續之前運行 RebuildNix"
      exit 1
    fi
  else
    if ! type home-manager >/dev/null 2>&1; then
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
      nix-shell -p git home-manager --run "bash -c '. src/config-files/.shell_aliases.sh && RebuildNix'"
    fi
  fi

  if [ "$IS_NIXOS" != "1" ]; then
    cat >/tmp/load_nix.sh <<"EOF"
if [ -z "$PROVISION_NIX_LOADED" ]; then
  PROVISION_NIX_LOADED=1

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
  fi

  cat >>~/.zshrc <<"EOF"
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""
EOF

  # 要在 cron 腳本中使用 `nix`，可以將其新增至 crontab 中
  # `PATH=/home/igncp/.nix-profile/bin`
}
