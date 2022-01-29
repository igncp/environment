# ubuntu-beginning START

# remove the second instance of this function
install_system_package() {
  PACKAGE="$1"
  if [ "$PACKAGE" == "task" ]; then
    PACKAGE="taskwarrior"
  fi
  if [ ! -z "$2" ]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: sudo apt-get install -y $PACKAGE"
    sudo apt-get install -y "$PACKAGE"
  fi
}

exit_if_failed_check() {
  if [ -n "$UBUNTU_CHECKS" ]; then
    echo "$1"
    echo "ERROR"; exit 1
  fi
}

UBUNTU_CHECKS="$(grep -ni "the_silver"_searcher ~/project/provision/provision.sh || true)"
if [ -n "$UBUNTU_CHECKS" ]; then
  sed -i 's|the_silver''_searcher|silversearcher-ag|' ~/project/provision/provision.sh
fi
exit_if_failed_check "Found wrong silver searcher installer. Automatically replaced. Run again."

UBUNTU_CHECKS="$(grep -ni "install_pac""man_package" ~/project/provision/provision.sh || true)"
if [ -n "$UBUNTU_CHECKS" ]; then
  sed -i 's|install_''pac''man_package|install_system_package|' ~/project/provision/provision.sh
fi
exit_if_failed_check "Found wrong installation functions. Automatically replaced. Run again."

UBUNTU_CHECKS="$(grep -ni "pac""man" ~/project/provision/provision.sh || true)"
exit_if_failed_check "$UBUNTU_CHECKS"

# this disables the * when typing a password
if [ -f /etc/sudoers.d/0pwfeedback ]; then
  sudo mv  /etc/sudoers.d/0pwfeedback.disabled
fi

if ! type nvim > /dev/null 2>&1 ; then
  cd /tmp && rm -rf nvim-linux* && wget https://github.com/neovim/neovim/releases/download/v0.6.1/nvim-linux64.tar.gz
  tar -xf ./nvim-linux64.tar.gz
  mv nvim-linux64 ~/nvim
  cd ~
fi
cat >> ~/.shellrc <<"EOF"
export PATH="$PATH:/home/igncp/nvim/bin"
EOF

cat >> ~/.shell_aliases <<"EOF"
alias SystemListInstalled='apt list --installed'
alias AptLog='tail -f /var/log/apt/term.log'
alias UbuntuVersion='lsb_release -a'
EOF

install_system_package python3
install_system_package python3-pip pip3

if ! type pip > /dev/null 2>&1 ; then
  sudo cp /usr/bin/pip3 /usr/bin/pip
fi

if [ ! -f ~/.check-files/ubuntu-dev ]; then
  # used by other provisions like rust
  sudo apt-get install -y pkg-config libssl-dev
  mkdir -p ~/.check-files; touch ~/.check-files/ubuntu-dev
fi

# ubuntu-beginning END
