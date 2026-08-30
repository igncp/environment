{
  description = "Root flake for NixOS, Nix shells and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty";
    nixgl.url = "github:nix-community/nixGL";
    nixos-raspberry.url = "github:nvmd/nixos-raspberrypi";
    llm-agents.url = "github:numtide/llm-agents.nix";
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
    nixgl,
    disko,
    nixos-raspberry,
    llm-agents,
  }: let
    user = builtins.getEnv "USER";
  in let
    per-system = flake-utils.lib.eachDefaultSystem (
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
            nixgl-pkgs
            nixos-hardware
            nixpkgs
            pkgs
            stable-pkgs
            system
            unstable
            nixos-raspberry
            llm-agents
            disko
            ;
        };
        nixos-systems = import ./src/nix/systems.nix {
          inherit pkgs stable-pkgs nixos-generators system nixpkgs;
        };
        nixgl-pkgs = import nixgl {};
      in {
        inherit devShells;
        nixosConfigurations = nixos-entry;
        packages =
          {
            homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [./src/nix/home-manager/home.nix];
              extraSpecialArgs = {inherit pkgs nixgl-pkgs ghostty llm-agents;};
            };
            check = pkgs.writeShellApplication {
              name = "check-environment";
              runtimeInputs = [pkgs.statix];
              text = "statix check src";
            };
          }
          // nixos-systems;
      }
    );
  in
    per-system
    // {
      nixosConfigurations = per-system.nixosConfigurations.${builtins.currentSystem};
    };
}
