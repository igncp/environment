#!/usr/bin/env bash

set -e

provision_setup_nix() {
  mkdir -p ~/.config/nix
  mkdir -p ~/.pip

  if ! type nix >/dev/null 2>&1; then
    mkdir -p ~/.local/state/home-manager/profiles

    if [ "$IS_MAC" ]; then
      sh <(curl -L https://nixos.org/nix/install)
      sudo mkdir -p /nix/var/nix/profiles/per-user/igncp
      sudo chown igncp /nix/var/nix/profiles/per-user/igncp
    else
      if ! type curl >/dev/null 2>&1; then
        if [ "$IS_DEBIAN" == "1" ]; then
          # The user may not be in the `sudo` group yet, can add with
          # `/usr/sbin/usermod -a -G sudo $USER`
          su -c 'apt-get update && apt-get install -y curl'
          su -c 'mkdir -p /nix/var/nix/profiles/per-user/igncp'
          su -c 'chown igncp /nix/var/nix/profiles/per-user/igncp'
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
      echo "You need to install packages"
      echo 'Run RebuildNixOS before continuing'
      exit 1
    fi
  else
    if ! type home-manager >/dev/null 2>&1; then
      # The user should be in the sudoers file for this to work
      sudo mkdir -p /nix/var/nix/profiles/per-user/igncp
      sudo mkdir -p /nix/var/nix/db/
      sudo mkdir -p /nix/var/nix/temproots/

      sudo chown -R igncp /nix/var/nix/profiles/per-user
      sudo chown -R igncp /nix/var/nix/gcroots/per-user || true
      sudo chown -R igncp /nix/var/nix/db/
      sudo chown -R igncp /nix/var/nix/temproots/

      # Running in docker
      if [ -z "$(ps aux | grep nix-daemon | grep -v grep || true)" ]; then
        sudo /nix/var/nix/profiles/default/bin/nix-daemon 2>&1 >/dev/null &
      else
        echo "Nix daemon is already running"
      fi

      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      sleep 10
      nix-shell -p git home-manager --run "bash -c '. src/config-files/.shell_aliases.sh && SwitchHomeManager'"
    fi
  fi

  cat >>~/.zshrc <<"EOF"
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""
EOF

  if [ "$IS_NIXOS" != "1" ]; then
    cat >>~/.shellrc <<"EOF"
if [ -f "~/.nix-profile/etc/profile.d/nix.sh" ]; then
  . ~/.nix-profile/etc/profile.d/nix.sh
fi

if [ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
  . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
fi
EOF
  fi

  # To use `nix` inside of a cron script, can add this inside the crontab
  # `PATH=/home/igncp/.nix-profile/bin`
}
