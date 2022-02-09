#!/usr/bin/env bash

# top START

set -e
# set -o xtrace # displays commands, helpful for debugging errors

if [ -z "$(whoami | grep igncp || true)" ]; then
  echo 'You should run this command as the igncp user'
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

if [ ! -f ~/.check-files/theme ]; then
  mkdir -p ~/.check-files
  echo 'light' > ~/.check-files/theme
fi
ENVIRONMENT_THEME="$(cat ~/.check-files/theme)" # light | dark
PROVISION_OS=''
ARM_ARCH="$(uname -m | grep arm)"

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

# top END
