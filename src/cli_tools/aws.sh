#!/usr/bin/env bash

set -e

# https://docs.aws.amazon.com/cli/latest/reference/
provision_setup_cli_tools_aws() {
  cat >>~/.zshrc <<'EOF'
if type aws > /dev/null 2>&1 ; then
  if ! type complete > /dev/null 2>&1 ; then
    autoload bashcompinit && bashcompinit
   fi
  complete -C "$(type -a aws_completer | head -n 1)" aws
fi
EOF

  cat >>~/.shell_aliases <<'EOF'
GimmeAWS() {
  rm -rf ~/gimme-aws-creds

  if [ -z "$(docker images | grep gimme-aws-creds)" ]; then
    (cd ~ && git clone https://github.com/Nike-Inc/gimme-aws-creds.git && cd gimme-aws-creds \
      && docker build \
        --progress=plain \
        -t gimme-aws-creds .)
    rm -rf ~/gimme-aws-creds
  fi

  touch ~/.okta_aws_login_config
  mkdir -p ~/.aws
  touch ~/.aws/credentials

  docker run -it --rm \
    -v ~/.aws/credentials:/root/.aws/credentials \
    -v ~/.okta_aws_login_config:/root/.okta_aws_login_config \
    gimme-aws-creds
}
EOF
}
