#!/usr/bin/env bash

set -e

provision_setup_crypto() {
  # Requires GO
  if [ -f "$PROVISION_CONFIG"/go-cosmos ]; then
    cat >>~/.shell_aliases <<'EOF'
alias Ignite='docker run --rm -v $(pwd):/app -w /app ignitehq/cli'
EOF
  fi

  if [ -f "$PROVISION_CONFIG"/solana ]; then
    if ! type "solana" >/dev/null 2>&1; then
      cd ~ && rm -rf solana
      git clone https://github.com/solana-labs/solana.git --depth 1
      cd ~/development/environment
      nix develop .#solana -c bash \
        -c 'cd ~/solana && ./cargo build -p solana-cli -p solana-keygen --release'
      sudo cp ~/.scripts/cargo_target/release/solana* /usr/local/bin/environment_scripts/
      sudo chmod +x /usr/local/bin/environment_scripts/solana*
      sudo chown $USER /usr/local/bin/environment_scripts/solana*
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
