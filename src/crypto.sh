#!/usr/bin/env bash

set -e

provision_setup_crypto() {
  # Requires GO
  if [ -f "$PROVISION_CONFIG"/go-cosmos ]; then
    if ! type "ignite" >/dev/null 2>&1; then
      echo "Installing ignite"
      curl https://get.ignite.com/cli@! | bash
    fi
  fi

  if [ -f "$PROVISION_CONFIG"/solana ]; then
    if ! type "solana" >/dev/null 2>&1; then
      cd ~ && rm -rf solana
      git clone https://github.com/solana-labs/solana.git --depth 1
      cd ~/development/environment
      nix develop .#solana -c bash \
        -c 'cd ~/solana && ./cargo build -p solana-cli -p solana-keygen --release'
      sudo cp ~/.scripts/cargo_target/release/solana* /usr/local/bin/
      sudo rm -rf ~/solana
    fi

    if [ ! -f ~/.config/solana/cli/config.yml ]; then
      solana config set --url https://api.devnet.solana.com
    fi

    cat >>~/.shell_aliases <<EOF
alias SolanaBalance="solana balance"
EOF

    # Example of new keypair
    # solana-keygen new --outfile ~/my-solana-wallet/my-keypair.json
  fi
}
