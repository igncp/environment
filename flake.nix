{
  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/23.05";};
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    unstable,
    home-manager,
  }: let
    hostname = (import ./nixos/flake-config.nix).hostname;
  in {
    nixosConfigurations = {
      ${hostname} = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/configuration.nix
        ];
        specialArgs = {inherit unstable home-manager;};
      };
    };
  };
}
