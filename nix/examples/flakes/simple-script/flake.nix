# You can execute this directly with: `nix run .#`
# https://www.ertt.ca/nix/shell-scripts/
{
  description = "A best script!";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        my-name = "my-script";
        my-buildInputs = with pkgs; [cowsay ddate];
        my-script-content = pkgs.writeScriptBin my-name (builtins.readFile ./simple-script.sh);
        my-script = my-script-content.overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        defaultPackage = packages.my-script;
        packages.my-script = pkgs.symlinkJoin {
          name = my-name;
          paths = [my-script] ++ my-buildInputs;
          buildInputs = [pkgs.makeWrapper];
          postBuild = "wrapProgram $out/bin/${my-name} --prefix PATH : $out/bin";
        };
      }
    );
}
