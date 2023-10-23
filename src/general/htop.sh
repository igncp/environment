#!/usr/bin/env bash

set -e

provision_setup_general_htop() {
  # https://www.thegeekstuff.com/2011/09/linux-htop-examples
  # C: configuration, w: see command wrapped
  install_system_package htop
  mkdir -p ~/.config/htop
  cp ~/development/environment/src/config-files/htoprc ~/.config/htop/htoprc

  cat >>~/.shell_aliases <<"EOF"
alias HTopCPU='htop -s PERCENT_CPU -d 6000'
alias HTopMem='htop -s PERCENT_MEM -d 6000'
EOF
}
