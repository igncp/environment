# Shell 別名應在別名檔案中定義，檢查二進位檔案是否可用
{pkgs}: let
  lua-config = import ../common/lua.nix {
    inherit pkgs;
    base_config = "";
  };
  lib = pkgs.lib;
  base-config = ../../../project/.config;
  cli-pkgs = import ../common/cli.nix {
    inherit base-config pkgs;
    lib = pkgs.lib;
  };

  cli-extra-shell = import ./cli-extra.nix {inherit pkgs;};
  python-extra-shell = import ./python.nix {inherit pkgs;};
  docker-extra-shell = import ./docker.nix {inherit pkgs lib;};

  go-pkgs = import ../common/go.nix {
    inherit pkgs;
    base_config = "";
  };

  is_linux =
    (pkgs.system == "x86_64-linux")
    || (pkgs.system == "aarch64-linux")
    || pkgs.system == "armv7l-linux";

  base_config = "";

  php-pkgs = import ../common/php.nix {
    inherit pkgs base_config;
  };
in
  {
    # For running in environments without Home Manager (e.g. servers)
    environment = pkgs.mkShell {
      packages = [] ++ cli-pkgs.pkgs-list;
    };

    ai = pkgs.mkShell {
      packages = with pkgs; [
        python313Packages.huggingface-hub
      ];
    };

    aws = pkgs.mkShell {
      packages = with pkgs; [awscli2];
    };

    go = pkgs.mkShell {
      packages = go-pkgs.pkgs-shell;
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
        pkgs.unrar
        unzip
        xz # https://github.com/tukaani-project/xz
        zip
        zstd # https://github.com/facebook/zstd
      ];
    };

    kube = pkgs.mkShell {
      packages = with pkgs; [
        # k3s # 評論是因為與 kubectl 衝突
        argocd
        kompose # https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/
        kubectl
        kubernetes-helm
        minikube
      ];
    };

    nix = pkgs.mkShell {
      packages = with pkgs; [
        colmena # https://github.com/zhaofengli/colmena
        nix-du # https://github.com/symphorien/nix-du
        # 首先你必須運行`nix-index`(大約需要30分鐘)
        nix-index # https://github.com/nix-community/nix-index
        pkgs.nix-init # https://github.com/nix-community/nix-init
      ];
    };

    performance = pkgs.mkShell {
      # https://www.brendangregg.com/blog/2024-03-24/linux-crisis-tools.html
      packages = with pkgs;
        [
          hyperfine # https://github.com/sharkdp/hyperfine
          vegeta
          tcpdump # https://www.tcpdump.org/
          ethtool # https://mirrors.edge.kernel.org/pub/software/network/ethtool/
        ]
        ++ (
          if is_linux
          then [
            bpftrace
            iproute2
            sysstat
            tiptop
            util-linux
          ]
          else []
        );
    };

    network = pkgs.mkShell {
      packages = with pkgs; [
        hurl # https://github.com/Orange-OpenSource/hurl
        mitmproxy # https://github.com/mitmproxy/mitmproxy
      ];
    };

    database = pkgs.mkShell {
      packages = with pkgs; [
        iredis # https://github.com/laixintao/iredis
        pgcli # https://github.com/dbcli/pgcli
      ];
    };

    php = pkgs.mkShell {
      packages = php-pkgs.pkgs-list-full;
    };

    lua = pkgs.mkShell {
      packages = lua-config.lua_pkgs;
    };

    windows = pkgs.mkShell {
      packages = with pkgs; [
        ms-sys
        ntfs3g
        parted
        woeusb-ng
      ];
    };

    qemu = pkgs.mkShell {
      packages = with pkgs; [
        libarchive # 對於帶有 qemu 的 aarch64 機器的 `bsdtar`
        multipath-tools # 對於帶有 qemu 的 aarch64 機器的 `kpartx`
        qemu
        quickemu
      ];
    };

    video = pkgs.mkShell {
      packages = with pkgs; [
        ffmpeg
      ];
    };

    proto = pkgs.mkShell {
      packages = with pkgs; [
        buf # https://github.com/bufbuild/buf
        protobuf
      ];
    };

    kotlin = pkgs.mkShell {
      packages = with pkgs; [
        gradle
        kotlin
        ktlint
      ];
      JAVA_11_HOME = "${pkgs.jdk11}/lib/openjdk";
      shellHook = ''
        if [ ! -d $HOME/nix-dirs/.kotlin-language-server ]; then
          mkdir -p $HOME/nix-dirs/
          git clone https://github.com/fwcd/kotlin-language-server.git ~/nix-dirs/.kotlin-language-server
          mkdir -p ~/.kotlin-language-server/.gradle/buildOutputCleanup
          (cd ~/nix-dirs/.kotlin-language-server && ./gradlew :server:installDist -PjavaVersion=19)
        fi
      '';
    };

    clang = pkgs.mkShell {
      buildInputs = with pkgs; [
        ncurses.dev
      ];
      packages = with pkgs;
        [
          astyle
          check
          ctags
          gdb
        ]
        ++ (
          if is_linux
          then [pkgs.valgrind]
          else []
        );
    };

    ansible = pkgs.mkShell {
      packages = with pkgs; [
        ansible
        ansible-lint
      ];
    };

    haskell = pkgs.mkShell {
      packages = [
        (pkgs.haskellPackages.ghcWithPackages (pkgs: [pkgs.turtle]))
        pkgs.haskell-language-server
      ];
    };

    images = pkgs.mkShell {
      packages = with pkgs; [
        imagemagick
        libwebp
      ];
    };
  }
  // docker-extra-shell
  // cli-extra-shell
  // python-extra-shell
