{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # This commit was found by searching directly in the repo:
  # `git log -S16.9.0 -- pkgs/development/web/nodejs/v16.nix`
  inputs.nodepkg.url = "github:NixOS/nixpkgs/f60eca11eff3966f2b39a1c6e8acd1a17cd48da7";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    flake-utils,
    nixpkgs,
    nodepkg,
    self,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nodepkg {inherit system;};
      in {
        devShells.default = nixpkgs.legacyPackages."${system}".mkShell {
          buildInputs = [pkgs.nodejs-16_x];
        };
      }
    );
}
