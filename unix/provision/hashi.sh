# hashi START

install_vim_package hashivim/vim-terraform # https://github.com/hashivim/vim-terraform

if ! type terraform > /dev/null 2>&1 ; then
  if [ "$PROVISION_OS" == "MAC" ]; then
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  fi
fi

# hashi END
