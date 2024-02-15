{
  # Keep these in sync with the environment repo by using `NixSyncInput`
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
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
        pkgs = import nixpkgs {inherit system;};
        unstable-pkgs = import unstable {inherit system;};
        is-darwin = system == "x86_64-darwin" || system == "aarch64-darwin";
      in {
        devShells.default = nixpkgs.legacyPackages."${system}".mkShell {
          buildInputs =
            [unstable-pkgs.go_1_21 pkgs.ruby]
            ++ (
              if is-darwin
              then [unstable-pkgs.darwin.apple_sdk.frameworks.Security]
              else []
            );
          shellHook = ''
            echo "Hello from ${system}!"
          '';
        };
      }
    );
}
