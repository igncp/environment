# ubuntu-beginning START

# remove the second instance of this function
install_system_package() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
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

UBUNTU_CHECKS="$(grep -ni "the_silver"_searcher /project/provision/provision.sh)"
if [ -n "$UBUNTU_CHECKS" ]; then
  sed -i /project/provision/provision.sh 's|the_silver''_searcher|silversearcher-ag|'
fi
exit_if_failed_check "Found wrong silver searcher installer. Automatically replaced. Run again."

UBUNTU_CHECKS="$(grep -ni "install_pac""man_package" /project/provision/provision.sh)"
if [ -n "$UBUNTU_CHECKS" ]; then
  sed -i /project/provision/provision.sh 's|install_''pac''man_package|install_system_package|'
fi
exit_if_failed_check "Found wrong installation functions. Automatically replaced. Run again."

UBUNTU_CHECKS="$(grep -ni "python-pip"" pip3" /project/provision/provision.sh)"
if [ -n "$UBUNTU_CHECKS" ]; then
  sed -i /project/provision/provision.sh 's|python-pip'' pip3|python3-pip pip3|'
fi
exit_if_failed_check "Found wrong installation for python. Automatically replaced. Run again."

UBUNTU_CHECKS="$(grep -ni "pac""man" /project/provision/provision.sh)"
exit_if_failed_check "$UBUNTU_CHECKS"

if ! type nvim > /dev/null 2>&1 ; then
  echo "in order to use autocomplete, use the latest version of neovim"
  echo "download the release from: https://github.com/neovim/neovim/releases/"
  exit 1
fi

# ubuntu-beginning END

