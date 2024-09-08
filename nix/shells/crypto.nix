{pkgs}: let
  # @upgrade
  solanaCommitSha = "e0203f2";

  rust-config = import ../common/rust.nix {
    inherit pkgs;
    base_config = "unused";
  };
  protobuf-pkgs = with pkgs; [
    buf # https://github.com/bufbuild/buf
    protobuf
  ];
  ethereum-etl = import ../common/ethereum-etl.nix {inherit pkgs;};
in {
  cosmos = pkgs.mkShell {
    packages = with pkgs; [clang protobuf-pkgs];
  };

  solana = pkgs.mkShell {
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    shellHook =
      rust-config.shellHook
      + ''
        set -e
        if [ ! -f ~/nix-dirs/solana_bin/solana ]; then
          rm -rf ~/nix-dirs/solana && mkdir -p ~/nix-dirs
          git clone https://github.com/solana-labs/solana.git ~/nix-dirs/solana
          (cd ~/nix-dirs/solana && git reset --hard ${solanaCommitSha} \
            && ./cargo build --release)
          mkdir -p ~/nix-dirs/solana_bin
          mv ~/.scripts/cargo_target/release/solana* ~/nix-dirs/solana_bin
          mv ~/.scripts/cargo_target/release/cargo-* ~/nix-dirs/solana_bin
        fi

        if [ ! -f ~/nix-dirs/solana_bin/spl-token ]; then
          cargo install spl-token-cli
          mv ~/.cargo/bin/spl-token ~/nix-dirs/solana_bin
        fi

        export PATH="$HOME/nix-dirs/solana_bin:$PATH"
        export SBF_SDK_PATH="$HOME/nix-dirs/solana"

        if [ ! -f ~/.config/solana/cli/config.yml ]; then
          solana config set --url https://api.devnet.solana.com
        fi
      '';
    packages = with pkgs;
      [pkg-config clang cmake]
      ++ protobuf-pkgs
      ++ rust-config.pkgs-list
      ++ (
        if system == "aarch64-darwin"
        then []
        else [udev]
      );
  };

  ethereum-etl = pkgs.mkShell {
    packages = ethereum-etl.packages;
    shellHook = ethereum-etl.shellHook;
  };

  # https://github.com/protofire/eth-cli/blob/master/docs/COMMANDS.md
  ethereum-cli = pkgs.mkShell {
    packages = [pkgs.nodejs_20];
    shellHook = ''
      if ! type -P eth &>/dev/null; then
        npm i -g eth-cli
      fi
    '';
  };

  gaiad = pkgs.mkShell {
    packages = with pkgs; [clang protobuf-pkgs go];
    shellHook = ''
      if [ ! -f ~/.go-workspace/bin/gaiad ]; then
        mkdir -p ~/nix-dirs
        git clone https://github.com/cosmos/gaia.git --depth 1 ~/nix-dirs/gaia
        (cd ~/nix-dirs/gaia && make install)
      fi
    '';
  };
}
