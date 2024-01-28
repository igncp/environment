# Shell aliases should  be defined in the aliases files, checking if binary is
# available
{
  pkgs,
  unstable,
}: let
  unstable_pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  rust-config = import ../common/rust.nix {inherit pkgs;};
  crypto-shells = import ./crypto.nix {inherit pkgs;};
  cli-extra-shell = import ./cli-extra.nix {inherit pkgs;};
in
  {
    aws = pkgs.mkShell {
      packages = with pkgs; [awscli2];
    };
    backup = pkgs.mkShell {
      packages = with pkgs; [awscli2];
    };
    compression = pkgs.mkShell {
      packages = with pkgs; [
        bzip2
        gzip
        p7zip
        pigz # https://github.com/madler/pigz
        ugrep # https://github.com/Genivia/ugrep
        unstable_pkgs.unrar
        unzip
        xz # https://github.com/tukaani-project/xz
        zip
        zstd # https://github.com/facebook/zstd
      ];
    };
    kube = pkgs.mkShell {
      packages = with pkgs; [
        helm
        k3s
        kompose # https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/
        kubectl
        minikube
      ];
    };
    nix = pkgs.mkShell {
      packages = with pkgs; [
        nix-du # https://github.com/symphorien/nix-du
        unstable_pkgs.nix-init # https://github.com/nix-community/nix-init
      ];
    };
    load-testing = pkgs.mkShell {
      packages = with pkgs; [vegeta];
    };
    rust = pkgs.mkShell {
      packages = rust-config.pkgs-list;
      shellHook = rust-config.shellHook;
    };
    video = pkgs.mkShell {
      packages = with pkgs; [
        ffmpeg
      ];
    };
  }
  // crypto-shells
  // cli-extra-shell
