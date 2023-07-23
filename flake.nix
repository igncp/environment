{
  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/23.05";};
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    unstable,
  }: let
    hostname = (import ./nixos/flake-config.nix).hostname;
  in {
    nixosConfigurations = {
      ${hostname} = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/configuration.nix
        ];
        specialArgs = {inherit unstable;};
      };
    };
  };
}
