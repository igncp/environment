#!/usr/bin/env bash

set -e

. src/cli_tools/aws.sh
. src/cli_tools/github.sh
. src/cli_tools/hasura.sh
. src/cli_tools/mysql.sh
. src/cli_tools/postgres.sh

provision_setup_cli_tools() {
  if [ -f "$PROVISION_CONFIG"/cli-vercel ]; then
    install_node_modules vercel
  fi

  # https://nixos.wiki/wiki/OpenVPN
  if [ -f "$PROVISION_CONFIG"/cli-openvpn ]; then
    mkdir -p ~/.openvpn

    cat >~/.openvpn/_start_cli_template.sh <<"EOF"
#!/usr/bin/env bash
set -e
sudo openvpn \
  --config $HOME/.openvpn/LOCATION.ovpn \
  --script-security 2 \
  --auth-user-pass $HOME/.openvpn/creds.txt \
  --up /etc/openvpn/update-systemd-resolved \
  --down /etc/openvpn/update-systemd-resolved \
  --dhcp-option 'DOMAIN-ROUTE .' \
  --down-pre
EOF
  fi

  # The `doctl completion zsh` and the ohmyzsh plugin didn't work during tests
  cat >>~/.shell_aliases <<"EOF"
if type doctl >/dev/null 2>&1; then
  # Keep the token encrypted and don't keep the user logged in
  alias DOLogin='doctl auth init'
  alias DOLogout='doctl auth remove --context default'
  alias DODroplets='doctl compute droplet list'
fi
EOF

  # Potential installs:
  # - https://github.com/firebase/firebase-tools
  # - https://support.crowdin.com/cli-tool/

  provision_setup_cli_tools_aws
  provision_setup_cli_tools_hasura
  provision_setup_cli_tools_mysql
  provision_setup_cli_tools_postgres
}
