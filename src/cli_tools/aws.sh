#!/usr/bin/env bash

set -e

# https://docs.aws.amazon.com/cli/latest/reference/
provision_setup_cli_tools_aws() {
  cat >>~/.bashrc <<EOF
if type aws > /dev/null 2>&1 ; then
  complete -C '/usr/local/bin/aws_completer' aws
fi
EOF

  cat >>~/.zshrc <<EOF
if type aws > /dev/null 2>&1 ; then
  if ! type complete > /dev/null 2>&1 ; then
    autoload bashcompinit && bashcompinit
  fi
  complete -C '/usr/local/bin/aws_completer' aws
fi
EOF
}
