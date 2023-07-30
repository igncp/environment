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
          config = {
            permittedInsecurePackages = ["nodejs-16.20.1"];
          };
        };
        shell_pkgs = with pkgs; [nodejs_16 rustup awscli2 vim openssl];
        docker_local = pkgs.dockerTools.buildImage {
          name = "example-image";
          tag = "latest";
          config = {
            User = "igncp";
            WorkingDir = "/app";
            Env = ["SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"];
          };
          copyToRoot = with pkgs; [
            bashInteractive
            cacert
            dockerTools.binSh
            dockerTools.usrBinEnv
            git
            nix
            openssl
          ];
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
            buildInputs = shell_pkgs;
          };
          packages.docker_local = docker_local;
        }
    );
}
