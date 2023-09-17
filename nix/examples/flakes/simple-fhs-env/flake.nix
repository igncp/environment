# https://jorel.dev/NixOS4Noobs/fhs.html
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages."${system}";
      in {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            (pkgs.buildFHSUserEnv {
              # FHS environments don't allow running sudo, and with a good
              # reason, or someone could create a sudoers file and gain root
              # access for the host
              name = "example_fhs";

              runScript = "bash";
              targetPkgs = pkgs: with pkgs; [nodejs];
            })
          ];
          shellHook = ''
            example_fhs
          '';
        };
      }
    );
}
