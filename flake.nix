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
    nixos-raspberry = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    base-config = let
      working-directory = builtins.getEnv "PWD";
    in
      if working-directory != ""
      then "${working-directory}/project/.config"
      else "";
    env-config = import ./src/nix/build-env-config.nix {inherit base-config;};
    nixos-entry-fn = {
      pkgs,
      stable-pkgs,
      system,
      disko,
      as-module ? false,
      env-config,
    }: let
      nixgl-pkgs = import nixgl {pkgs = stable-pkgs;};
    in
      import ./src/nix/nixos/nixos-entry.nix {
        inherit
          ghostty
          home-manager
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
        nixgl-pkgs = import nixgl {pkgs = pkgs;};
        pkgs = import unstable {
          system = stable-pkgs.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
        devShells = import ./src/nix/shells/main.nix {
          inherit disko env-config llm-agents nixpkgs pkgs;
        };
        nixos-entry = nixos-entry-fn {
          inherit
            pkgs
            stable-pkgs
            system
            disko
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
                inherit disko env-config ghostty llm-agents nixgl-pkgs nixpkgs pkgs;
              };
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
      lib = {
        envConfig = env-config;
        nixosEntry = nixos-entry-fn;
        installEnvironment = import ./src/nix/nixos/install-environment.nix {inherit self;};
      };
    };
}
