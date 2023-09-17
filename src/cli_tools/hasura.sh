#!/usr/bin/env bash

set -e

provision_setup_cli_tools_hasura() {
  if [ ! -f "$PROVISION_CONFIG"/cli-hasura ]; then
    return
  fi

  echo 'export HASURA_GRAPHQL_ENABLE_TELEMETRY=false' >>~/.shellrc
}
