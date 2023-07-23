{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    flake-utils,
    nixpkgs,
    self,
  }:
    flake-utils.lib.eachDefaultSystem (
      system:
        with nixpkgs.legacyPackages."${system}"; rec {
          devShells.default = mkShell {
            buildInputs = let
              custom_exists = builtins.pathExists ./custom.nix;
            in
              [
                age
                alejandra
                bat
                go
                graphviz
                jq
                moreutils # For `sponge`
                neofetch
                neovim
                nmap
                nodejs
                openssl
                openvpn
                pkg-config # For at least the `openssl-sys` crate
                ranger
                rustup
                silver-searcher
                taskwarrior
                tmux
                wasm-pack
                zsh
              ]
              ++ (
                if custom_exists
                then ((import ./custom.nix {pkgs = nixpkgs.legacyPackages."${system}";}).extra_pkgs)
                else []
              );
            shellHook = ''
              ${zsh}/bin/zsh
            '';
          };
        }
    );
}
