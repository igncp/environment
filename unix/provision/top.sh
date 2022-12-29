#!/usr/bin/env bash

# top START

set -e
# set -o xtrace # displays commands, helpful for debugging errors

if [ -n "$(whoami | grep root || true)" ]; then
  echo 'You should not be run as root'
  exit 1
fi

echo '# This file was generated from ~/project/provision/provision.sh' > ~/.shellrc
echo '# This file was generated from ~/project/provision/provision.sh' > ~/.shell_aliases
echo '# This file was generated from ~/project/provision/provision.sh' > ~/.shell_sources
echo '# This file was generated from ~/project/provision/provision.sh' > ~/.bashrc
echo '# This file was generated from ~/project/provision/provision.sh' > ~/.bash_profile
echo '# This file was generated from ~/project/provision/provision.sh' > ~/.zshrc
echo '# This file was generated from ~/project/provision/provision.sh' > ~/.xinitrc
echo '# This file was generated from ~/project/provision/provision.sh' > ~/.inputrc

rm -rf /tmp/expected-vscode-extensions

mkdir -p ~/project/.config
mkdir -p ~/.check-files
mkdir -p ~/.scripts

if [ ! -f ~/project/.config/theme ]; then
  echo 'dark' > ~/project/.config/theme
fi
ENVIRONMENT_THEME="$(cat ~/project/.config/theme)" # light | dark
PROVISION_OS=''
ARM_ARCH="$(uname -m | grep -E '(arm|aarch64)' || true)"

case "$(uname -s)" in
   Darwin)
     PROVISION_OS='MAC'
     ;;
   Linux)
     PROVISION_OS='LINUX'
     ;;
   CYGWIN*|MINGW32*|MSYS*|MINGW*)
     PROVISION_OS='WINDOWS'
     ;;
   *)
     echo 'Other OS'
     ;;
esac

if [ "$PROVISION_OS" == "LINUX" ]; then
  mkdir -p ~/.config/systemd/user
fi

# top END
