# # To run the hello property in the flake:
# nix run .#hello

# # TO run the dev shell
# nix develop
{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs"; };

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in {
      packages.aarch64-linux.hello = pkgs.hello;

      devShell.aarch64-linux =
        pkgs.mkShell { buildInputs = [ self.packages.aarch64-linux.hello pkgs.cowsay ]; };
   };
}
