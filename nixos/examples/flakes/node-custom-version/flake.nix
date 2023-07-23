# 8.1.4 found here:
# https://lazamar.co.uk/nix-versions/?package=nodejs&version=8.1.4&fullName=nodejs-8.1.4&keyName=nodejs-8_x&revision=9748e9ad86159f62cc857a5c72bc78f434fd2198&channel=nixpkgs-unstable#instructions
# In this case it can't be used as an input because it doesn't have a flake
{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    flake-utils,
    nixpkgs,
    self,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/9748e9ad86159f62cc857a5c72bc78f434fd2198.tar.gz";
          sha256 = "1k6mdfnwwwy51f7szggyh2dxjwrf9q431c0cnbi17yb21m9d4n26";
        }) {inherit system;};
      in rec {
        packages.node = pkgs.nodejs-8_x;
        devShells.default = nixpkgs.legacyPackages."${system}".mkShell {
          buildInputs = [pkgs.nodejs-8_x];
        };
      }
    );
}
