{
  description = "Root flake for NixOS, Nix shells and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.05";
    };
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = {
    home-manager,
    flake-utils,
    nixpkgs,
    self,
    unstable,
    ghostty,
    nixos-hardware,
    nixos-generators,
  }: let
    user = builtins.getEnv "USER";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        stable-pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import unstable {
          system = stable-pkgs.system;
          config.allowUnfree = true;
        };
        devShells = import ./src/nix/shells/main.nix {inherit pkgs;};
        nixos-entry = import ./src/nix/nixos/nixos-entry.nix {
          inherit
            ghostty
            home-manager
            nixos-hardware
            nixpkgs
            pkgs
            stable-pkgs
            system
            unstable
            ;
        };
        nixos-systems = import ./src/nix/systems.nix {
          inherit pkgs stable-pkgs nixos-generators system nixpkgs;
        };
      in {
        inherit devShells;
        packages =
          {
            nixosConfigurations = nixos-entry;
            homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [./src/nix/home-manager/home.nix];
              extraSpecialArgs = {inherit pkgs stable-pkgs ghostty;};
            };
          }
          // nixos-systems;
      }
    );
}
