# ubuntu-beginning START

install_system_package() {
  PACKAGE="$1"
  if [ "$PACKAGE" == "task" ]; then
    PACKAGE="taskwarrior"
  elif [ "$PACKAGE" == "the_silver_searcher" ]; then
    PACKAGE="silversearcher-ag"
  fi
  if [ ! -z "$2" ]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: sudo apt-get install -y $PACKAGE"
    sudo apt-get install -y "$PACKAGE"
  fi
}

# this disables the * when typing a password
if [ -f /etc/sudoers.d/0pwfeedback ]; then
  sudo mv  /etc/sudoers.d/0pwfeedback.disabled
fi

if ! type nvim > /dev/null 2>&1 ; then
  if [ -n "$ARM_ARCH" ]; then
    cd ~ ; rm -rf nvim-repo ; git clone https://github.com/neovim/neovim.git nvim-repo --depth 1 --branch release-0.6 ; cd nvim-repo
    # https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites
    sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
    make CMAKE_BUILD_TYPE=Release
    make CMAKE_INSTALL_PREFIX=$HOME/nvim install
    cd ~ ; rm -rf nvim-repo
  else
    cd /tmp && rm -rf nvim-linux* && wget https://github.com/neovim/neovim/releases/download/v0.6.1/nvim-linux64.tar.gz
    tar -xf ./nvim-linux64.tar.gz
    rm -rf ~/nvim
    mv nvim-linux64 ~/nvim
    cd ~
  fi
fi
cat >> ~/.shellrc <<"EOF"
export DEBIAN_FRONTEND=noninteractive
export PATH="$PATH:$HOME/nvim/bin"
EOF

cat >> ~/.shell_aliases <<"EOF"
alias SystemListInstalled='apt list --installed'
alias AptLog='tail -f /var/log/apt/term.log'
alias UbuntuVersion='lsb_release -a'
alias UbuntuFindPackageByFile="dpkg-query -S" # e.g. UbuntuFindPackageByFile '/usr/bin/ag'
EOF

install_system_package python3
install_system_package python3-pip pip3

if ! type pip > /dev/null 2>&1 ; then
  sudo cp /usr/bin/pip3 /usr/bin/pip
fi

if [ ! -f ~/.check-files/ubuntu-dev ]; then
  # used by other provisions like rust
  sudo apt-get install -y pkg-config libssl-dev
  touch ~/.check-files/ubuntu-dev
fi

sudo rm -rf ~/.scripts/motd_update.sh
cat > ~/.scripts/motd_update.sh <<"EOF"
echo "###" > /etc/motd
echo "Message created in $HOME/.scripts/motd_update.sh" >> /etc/motd
echo "Hello!" >> /etc/motd
echo "###" >> /etc/motd
echo "" >> /etc/motd
EOF
sudo chown root:root ~/.scripts/motd_update.sh

# ubuntu-beginning END
