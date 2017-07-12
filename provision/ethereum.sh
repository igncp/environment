# ethereum START

install_vim_package tomlion/vim-solidity

if ! type ethrun > /dev/null 2>&1 ; then
  ETHRUN_VER=v0.2.4
  cd ~; rm -rf ethereum-tmp; mkdir ethereum-tmp; cd ethereum-tmp
  wget "https://github.com/dapphub/ethrun/releases/download/$ETHRUN_VER/ethrun-v0.2.4-linux.tar.gz"
  tar -xvzf "ethrun-$ETHRUN_VER-linux.tar.gz"
  sudo mv ethrun /usr/bin
  cd ~; rm -rf ethereum-tmp
fi

# ethereum END
