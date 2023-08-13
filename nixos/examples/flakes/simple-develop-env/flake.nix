# Can run `nix develop` to start the shell

# In `.envrc` you can specify a flake in a different directory, for example:
# `use flake ~/env-job-nix --impure` : Here `--impure` is needed if installing
# packages like node16 which require a config in the home directory

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
        # pkgs/build-support/mkshell/default.nix
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            postgresql
            ruby
          ];
          shellHook = ''
            echo "Hello shell"
            export PATH="/home/igncp/.local/share/gem/ruby/3.1.0/bin:$PATH"
          '';
        };
      }
    );
}
