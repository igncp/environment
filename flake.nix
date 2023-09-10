{
  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/23.05";};
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Added for `v1.0` until it is available in `nixos-unstable`
    bun.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    bun,
    home-manager,
    nixpkgs,
    self,
    unstable,
  }: let
    hostname = (import ./nixos/flake-config.nix).hostname;
  in {
    nixosConfigurations = {
      ${hostname} = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/configuration.nix
        ];
        specialArgs = {inherit unstable home-manager bun;};
      };
    };
  };
}
