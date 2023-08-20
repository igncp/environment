{
  description = "Home Manager configuration of igncp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    go-21.url = "github:qowoz/nixpkgs/go-riscv";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    flake-utils,
    unstable,
    go-21,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          homeConfigurations."igncp" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [./home.nix];
            extraSpecialArgs = {inherit unstable go-21;};
          };
        };
      }
    );
}
