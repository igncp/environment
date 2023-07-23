# docker load < $(nix build .#docker_local)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        all_pkgs = with pkgs; [nodejs rustup awscli2 vim openssl];
        docker_local = pkgs.dockerTools.buildImage {
          name = "example-image";
          tag = "latest";
          config = {
            User = "igncp";
            WorkingDir = "/app";
          };
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = with pkgs;
              [
                bashInteractive
                coreutils
                gcc
                git
                nix
              ]
              ++ all_pkgs;
            pathsToLink = ["/bin"];
          };
          runAsRoot = ''
            #!${pkgs.runtimeShell}
            ${pkgs.dockerTools.shadowSetup}
            mkdir -p /etc/nix
            echo 'experimental-features = flakes nix-command' >> /etc/nix/nix.conf
            groupadd nixbld
            useradd -rm -u 1000 igncp
            usermod -a -G nixbld igncp
            mkdir /app
            chown igncp /app
          '';
        };
      in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = all_pkgs;
          };
          packages.docker_local = docker_local;
        }
    );
}
