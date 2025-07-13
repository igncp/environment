#!/usr/bin/env bash

set -euo pipefail

provision_setup_cli_tools_mysql() {
  if [ ! -f "$PROVISION_CONFIG"/mysql ]; then
    return
  fi

  cat >>~/.shell_aliases <<"EOF"
alias MySQLSize='sudo du -h /var/lib/mysql'
EOF
}
