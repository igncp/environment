#!/usr/bin/env bash

set -e

# https://docs.aws.amazon.com/cli/latest/reference/
provision_setup_cli_tools_aws() {
  if [ ! -f "$PROVISION_CONFIG"/cli-aws ]; then
    return
  fi

  cat >>~/.bashrc <<EOF
complete -C '/usr/local/bin/aws_completer' aws
EOF

  cat >>~/.zshrc <<EOF
if ! type complete > /dev/null 2>&1 ; then
  autoload bashcompinit && bashcompinit
fi
complete -C '/usr/local/bin/aws_completer' aws
EOF
}
