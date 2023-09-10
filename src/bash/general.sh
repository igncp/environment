#!/usr/bin/env bash

set -e

provision_setup_general() {
  cat >>~/.shell_aliases <<"EOF"
alias ShellFormat='shfmt -i 2 -w'
EOF
}
