{
  description = "Root flake for NixOS, Nix shells and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixos-raspberry = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {
    home-manager,
    colmena,
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
    base-config = let
      working-directory = builtins.getEnv "PWD";
    in
      if working-directory != ""
      then "${working-directory}/project/.config"
      else "";
    env-config = import ./src/nix/build-env-config.nix {inherit base-config;};
    nixgl-pkgs = import nixgl {};
    nixos-entry-fn = {
      pkgs,
      stable-pkgs,
      system,
      as-module ? false,
      env-config,
    }:
      import ./src/nix/nixos/nixos-entry.nix {
        inherit
          ghostty
          home-manager
          colmena
          nixos-hardware
          nixpkgs
          unstable
          nixos-raspberry
          llm-agents
          disko
          nixgl-pkgs
          pkgs
          stable-pkgs
          system
          env-config
          ;
        inherit as-module;
      };
  in let
    per-system = flake-utils.lib.eachDefaultSystem (
      system: let
        stable-pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import unstable {
          system = stable-pkgs.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
        devShells = import ./src/nix/shells/main.nix {
          inherit colmena env-config llm-agents pkgs;
        };
        nixos-entry = nixos-entry-fn {
          inherit
            pkgs
            stable-pkgs
            system
            env-config
            ;
        };
        nixos-systems = import ./src/nix/systems.nix {
          inherit pkgs stable-pkgs nixos-generators system nixpkgs;
        };
      in {
        inherit devShells;
        nixosConfigurations = nixos-entry;
        packages =
          {
            homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [./src/nix/home-manager/home.nix];
              extraSpecialArgs = {
                inherit colmena env-config ghostty llm-agents nixgl-pkgs pkgs;
              };
            };
            check = pkgs.writeShellApplication {
              name = "check-environment";
              runtimeInputs = [pkgs.statix];
              text = "statix check src";
            };
            colmena = colmena.packages.${system}.colmena;
          }
          // nixos-systems;
      }
    );
  in
    per-system
    // {
      nixosConfigurations = per-system.nixosConfigurations.${builtins.currentSystem};
      colmena =
        if env-config.colmena != ""
        then import env-config.colmena {inherit colmena env-config nixos-entry-fn nixpkgs;}
        else {};
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    };
}
