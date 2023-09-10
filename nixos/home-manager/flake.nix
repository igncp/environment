{
  description = "Home Manager configuration of igncp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Added for `v1.0` until it is available in `nixos-unstable`
    bun.url = "github:nixos/nixpkgs/master";
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
    bun,
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
            extraSpecialArgs = {inherit unstable bun;};
          };
        };
      }
    );
}
