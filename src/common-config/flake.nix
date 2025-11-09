{
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    flake-utils,
    self,
    unstable,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        unstable-pkgs = import unstable {inherit system;};
      in {
        devShells.default = unstable.legacyPackages."${system}".mkShell {
          buildInputs = with unstable-pkgs; [nodejs];
          shellHook = ''
            echo "Hello from ${system}!"
          '';
        };
      }
    );
}
