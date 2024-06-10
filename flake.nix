{
  description = "Root flake for NixOS, Nix shells and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
        stable_pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import unstable {
          system = stable_pkgs.system;
          config.allowUnfree = true;
        };
        hostname = (import /etc/nixos/configuration.nix {inherit pkgs;}).networking.hostName;
        devShells = import ./nix/shells/main.nix {inherit pkgs;};
      in {
        inherit devShells;
        packages = {
          nixosConfigurations = {
            "${hostname}" = nixpkgs.lib.nixosSystem {
              modules = [
                ./nix/nixos/configuration.nix
              ];
              specialArgs = {
                inherit stable_pkgs home-manager;
                user = "igncp"; # 硬編碼這個值，因為它等於 nixos 中的 “root”
              };
            };
          };
          homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [./nix/home-manager/home.nix];
            extraSpecialArgs = {inherit pkgs stable_pkgs;};
          };
        };
      }
    );
}
