# Can run `nix develop` to start the shell
{
  inputs = {nixpkgs.url = "github:nixos/nixpkgs";};

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
  in {
    packages.aarch64-linux.hello = pkgs.hello;

    devShell.aarch64-linux = pkgs.mkShell {
      packages = with pkgs; [
        sqlite
        zsh
      ];
    };
  };
}
