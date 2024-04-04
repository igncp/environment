{
  description = "Root flake for NixOS, Nix shells and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
    user = builtins.getEnv "USER";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        hostname = (import /etc/nixos/configuration.nix {inherit pkgs;}).networking.hostName;
        shells = import ./nix/shells/main.nix {inherit pkgs unstable;};
      in {
        devShells = shells;
        packages = {
          nixosConfigurations = {
            "${hostname}" = nixpkgs.lib.nixosSystem {
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
