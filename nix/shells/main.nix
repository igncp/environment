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
  python-extra-shell = import ./python.nix {inherit pkgs;};

  lib = pkgs.lib;
  is_linux =
    (pkgs.system == "x86_64-linux")
    || (pkgs.system == "aarch64-linux")
    || pkgs.system == "armv7l-linux";

  base_config = "";

  go-pkgs = import ../common/go.nix {
    inherit pkgs lib unstable base_config;
  };
  php-pkgs = import ../common/php.nix {
    inherit pkgs base_config;
  };
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

    go = pkgs.mkShell {
      packages = go-pkgs.pkgs-shell;
      # 對於 `dlv`: https://github.com/go-delve/delve/issues/3085#issuecomment-1419664637
      hardeningDisable = ["all"];
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
        colmena # https://github.com/zhaofengli/colmena
        nix-du # https://github.com/symphorien/nix-du
        # 首先你必須運行`nix-index`(大約需要30分鐘)
        nix-index # https://github.com/nix-community/nix-index
        unstable_pkgs.nix-init # https://github.com/nix-community/nix-init
      ];
    };

    performance = pkgs.mkShell {
      # https://www.brendangregg.com/blog/2024-03-24/linux-crisis-tools.html
      packages = with pkgs;
        [
          hyperfine # https://github.com/sharkdp/hyperfine
          procps # https://gitlab.com/procps-ng/procps
          vegeta
          tcpdump # https://www.tcpdump.org/
          ethtool # https://mirrors.edge.kernel.org/pub/software/network/ethtool/
        ]
        ++ (
          if is_linux
          then [
            bpftrace
            # cpuid
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
        usql # https://github.com/xo/usql
      ];
    };

    php = pkgs.mkShell {
      packages = php-pkgs.pkgs-list-full;
    };

    nodenv = pkgs.mkShell {
      packages = [pkgs.nodenv];
      shellHook = ''
        mkdir -p $HOME/nix-dirs/nodenv/plugins
        # This is used in the provision to init nodenv
        export NODENV_ROOT="$HOME/nix-dirs/nodenv"
        eval "$(nodenv init -)"
        if [ ! -d $HOME/nix-dirs/nodenv/plugins/node-build ]; then
          git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
        fi
      '';
    };

    rust = pkgs.mkShell {
      packages = rust-config.pkgs-list ++ [pkgs.ncurses];
      shellHook = rust-config.shellHook;
    };

    lua = pkgs.mkShell {
      packages = with pkgs; [
        lua
        luajit

        # For local installs, use `--tree`: https://leafo.net/guides/customizing-the-luarocks-tree.html
        # It requires to set up the paths to load
        luarocks
      ];
    };

    ruby = pkgs.mkShell {
      packages = with pkgs; [
        ruby
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
  }
  // crypto-shells
  // cli-extra-shell
  // python-extra-shell
