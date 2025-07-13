#!/usr/bin/env bash

set -euo pipefail

provision_setup_crypto() {
  # Requires GO
  if [ -f "$PROVISION_CONFIG"/go-cosmos ]; then
    cat >>~/.shell_aliases <<'EOF'
alias Ignite='docker run --rm -v $(pwd):/app -w /app ignitehq/cli'

# https://github.com/CosmWasm/wasmd?tab=readme-ov-file#dockerized
# 僅適用於 amd64
WasmdSetup() {
  TEST_ACCOUNT=${1:-cosmos1pkptre7fdkl6gfrzlesjjvhxhlc3r4gmmk8rs6}
  docker volume rm -f wasmd_data
  docker run --rm -it \
    -e PASSWORD=foobar \
    -v wasmd_data:/root \
    cosmwasm/wasmd:latest /opt/setup_wasmd.sh $TEST_ACCOUNT
}
WasmdRun() {
  docker run --rm -it -p 26657:26657 -p 26656:26656 -p 1317:1317 \
    -v wasmd_data:/root \
    cosmwasm/wasmd:latest /opt/run_wasmd.sh
}
EOF
  fi

  cat >>~/.shellrc <<'EOF'
if [ -d "$HOME/.local/share/solana/install/active_release/bin" ]; then
  export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
fi
EOF

  # 產生新密鑰對的範例:
  # `solana-keygen new --outfile ~/my-solana-wallet/my-keypair.json`
  cat >>~/.shell_aliases <<EOF
if type solana > /dev/null 2>&1; then
  alias SolanaBalance="solana balance"
  alias SolanaListStakeAccounts='solana stakes --withdraw-authority'
  alias SolanaNewKeyPair='echo "Run: solana-keygen new --outfile ~/my-solana-wallet/my-keypair.json"'
  alias SolanaTestValidator='solana-test-validator'
fi
EOF
}
