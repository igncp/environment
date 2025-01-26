#!/usr/bin/env bash

set -e

provision_setup_general_htop() {
  if [ -f "$PROVISION_CONFIG"/no-htop ]; then
    sudo rm -rf ~/.local/bin/htop
    return
  elif [ "$IS_NIXOS" = "1" ] || [ "$IS_MAC" = "1" ] && ! type brew >/dev/null 2>&1; then
    return
  elif [ "$IS_PROVISION_UPDATE" = "1" ]; then
    sudo rm -rf ~/.local/bin/htop
  fi

  # https://github.com/htop-dev/htop

  if [ ! -f ~/.local/bin/htop ]; then
    sudo rm -rf ~/.local/htop
    cd ~ && sudo rm -rf .provision_install
    mkdir -p .provision_install && cd .provision_install
    git clone https://github.com/htop-dev/htop htop && cd htop

    if [ "$IS_DEBIAN" = "1" ]; then
      sudo apt install -y libncursesw5-dev autotools-dev autoconf automake build-essential
    elif [ "$IS_ARCH" = "1" ]; then
      sudo pacman -S --noconfirm ncurses automake autoconf gcc
    elif [ "$IS_MAC" = "1" ]; then
      brew install ncurses automake autoconf gcc libtool pkgconf
    fi

    echo "Building htop..."

    local EXTRA_ARGS=()

    if [ "$IS_MAC" != "1" ]; then
      local EXTRA_ARGS+=(--enable-static)
    fi

    rm -rf $HOME/.local/htop &&
      ./autogen.sh >/dev/null 2>&1 &&
      ./configure --prefix="$HOME/.local/htop" "${EXTRA_ARGS[@]}" >/dev/null 2>&1 &&
      make >/dev/null 2>&1 &&
      make install >/dev/null 2>&1 ||
      (echo "htop failed to build" && cd ~ && exit 1)

    cd ~ && sudo rm -rf .provision_install

    if [ "$IS_MAC" = "1" ]; then
      ln -s "$HOME/.local/htop/bin/htop" "$HOME/.local/bin/htop"
    else
      if [ "$IS_DEBIAN" = "1" ]; then
        sudo apt remove -y libncursesw5-dev autotools-dev autoconf automake build-essential
        sudo apt autoremove -y
      elif [ "$IS_ARCH" = "1" ]; then
        sudo pacman -S --noconfirm ncurses automake autoconf gcc
      fi

      mv "$HOME/.local/htop/bin/htop" "$HOME/.local/bin/htop"
      rm -rf $HOME/.local/htop
    fi
  fi

  # https://www.thegeekstuff.com/2011/09/linux-htop-examples
  # C: configuration, w: see command wrapped
  mkdir -p ~/.config/htop
  cp ~/development/environment/src/config-files/htoprc ~/.config/htop/htoprc

  cat >>~/.shell_aliases <<"EOF"
alias HTopCPU='sudo htop -s PERCENT_CPU -d 6000'
alias HTopMem='sudo htop -s PERCENT_MEM -d 6000'
EOF
}
