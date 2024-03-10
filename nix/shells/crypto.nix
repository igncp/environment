{pkgs}: let
  rust-config = import ../common/rust.nix {inherit pkgs;};
  protobuf-pkgs = with pkgs; [
    buf # https://github.com/bufbuild/buf
    protobuf
  ];
  ethereum-etl = import ../derivations/ethereum-etl.nix {inherit pkgs;};
in {
  cosmos = pkgs.mkShell {
    packages = with pkgs; [clang protobuf-pkgs];
  };

  solana = pkgs.mkShell {
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    shellHook = rust-config.shellHook;
    packages = with pkgs;
      [pkg-config]
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
