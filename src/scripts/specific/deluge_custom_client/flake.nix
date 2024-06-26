{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    flake-utils,
    nixpkgs,
    self,
    unstable,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        unstable-pkgs = import unstable {inherit system;};
      in {
        devShells.default = nixpkgs.legacyPackages."${system}".mkShell {
          buildInputs = with unstable-pkgs; [openssl openssl.dev pkg-config libiconv rustup ncurses];
          shellHook = ''
            echo "Hello from ${system}!"
          '';
        };
      }
    );
}
