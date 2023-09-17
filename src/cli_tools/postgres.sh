#!/usr/bin/env bash

set -e

provision_setup_cli_tools_postgres() {
  if [ ! -f "$PROVISION_CONFIG"/postgres ]; then
    return
  fi

  # Using with nix: https://mgdm.net/weblog/postgresql-in-a-nix-shell/
  cat >>~/.shell_aliases <<"EOF"
# Example to connect when started: `pgcli -h localhost -d postgres`
alias PostgresInitLocal='initdb -D .tmp/mydb'
alias PostgresStartLocal='pg_ctl -D .tmp/mydb -l logfile -o "--unix_socket_directories=$PWD" start'
alias PostgresStopLocal='pg_ctl -D .tmp/mydb -l logfile -o "--unix_socket_directories=$PWD" stop'
EOF
}
