#!/usr/bin/env bash

set -euo pipefail

provision_setup_general_shellcheck() {
  if [ ! -f "$PROVISION_CONFIG"/shellcheck ]; then
    return
  fi

  install_system_package shellcheck

  local DIRECTIVES=(
    2016 2028 2046 2059 2086 2088 1117 2143 2148 2164 2181
  )

  local TEXT=""
  for LIST_ITEM in "${DIRECTIVES[@]}"; do
    TEXT="$TEXT""SC$LIST_ITEM,"
  done

  # Remove the last comma
  TEXT="${TEXT%?}"

  echo "export SHELLCHECK_OPTS='-e $TEXT'" >>~/.shellrc
}
