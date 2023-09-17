{
  description = "Root flake for NixOS and Home Manager";

  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/23.05";};
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    home-manager,
    flake-utils,
    nixpkgs,
    self,
    unstable,
  }: let
    hostname = (import ./nix/nixos/flake-config.nix).hostname;
    user = builtins.getEnv "USER";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          nixosConfigurations = {
            ${hostname} = nixpkgs.lib.nixosSystem {
              modules = [
                ./nix/nixos/configuration.nix
              ];
              specialArgs = {inherit unstable home-manager;};
            };
          };
          homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [./nix/home-manager/home.nix];
            extraSpecialArgs = {inherit unstable;};
          };
        };
      }
    );
}
