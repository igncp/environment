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

cat >> ~/.shell_aliases <<"EOF"
ProvisionRustCompile() {
  (cd ~/project/scripts/misc/"$1" && cargo build --release)
}
ProvisionRustCompileAll() {
  for i in ~/project/scripts/misc/*; do
    if [ -d "$i" ]; then (cd "$i" && echo "$i" && cargo build --release); fi
  done
  for i in ~/project/scripts/toolbox/*; do
    if [ -d "$i" ]; then (cd "$i" && echo "$i" && cargo build --release); fi
  done
}
ProvisionScriptsCopyFromProjectIntoEnvironment() {
  rsync -rhv --delete ~/project/scripts/misc/ ~/development/environment/unix/scripts/misc/
  rsync -rhv --delete ~/project/scripts/toolbox/ ~/development/environment/unix/scripts/toolbox/
}
EOF

if [ -f "$HOME"/.cargo/env ]; then source "$HOME/.cargo/env"; fi # in case provision stopped before
cat >> ~/.shellrc <<"EOF"
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi
EOF

if ! type rustc > /dev/null 2>&1 ; then
  curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y --default-toolchain nightly
  source "$HOME/.cargo/env"
  rustup component add rust-src
  cargo install cargo-edit
fi

mkdir -p ~/.cargo
cat > ~/.cargo/config <<"EOF"
[build]
target-dir = ".scripts/cargo_target"
EOF

# top END
