{
  env-config,
  pkgs,
  lib,
  llm-agents,
}: let
  logdy = import ../derivations/logdy.nix {inherit pkgs;};

  is_linux =
    (pkgs.stdenv.hostPlatform.system == "x86_64-linux")
    || (pkgs.stdenv.hostPlatform.system == "aarch64-linux")
    || pkgs.stdenv.hostPlatform.system == "armv7l-linux";

  tmux-pkgs = with pkgs; [
    tmux # https://github.com/tmux/tmux
  ];

  lsp-pkgs = with pkgs; [
    lua-language-server
  ];
in {
  pkgs-list = with pkgs;
    [
      # aapt # https://developer.android.com/tools/aapt2
      act # https://github.com/nektos/act
      age # https://github.com/FiloSottile/age
      alejandra # https://github.com/kamadorueda/alejandra
      bash
      bat # https://github.com/sharkdp/bat
      bc
      ccls # https://github.com/MaskRay/ccls
      cmus # https://github.com/cmus/cmus
      coreutils-full
      crystal # 供 tmux-fingers 使用
      shards # 來自 Crystal，供 tmux-fingers 使用
      curl
      d2 # https://github.com/terrastruct/d2
      difftastic # https://github.com/Wilfred/difftastic
      direnv # https://github.com/direnv/direnv
      dua # https://github.com/Byron/dua-cli
      entr # https://github.com/eradman/entr
      fastfetch # https://github.com/fastfetch-cli/fastfetch
      fd # https://github.com/sharkdp/fd
      fzf # https://github.com/junegunn/fzf
      gh # https://github.com/cli/cli
      git
      git-crypt # https://github.com/AGWA/git-crypt
      git-extras
      git-lfs
      gnugrep
      gnupg
      gnused
      go-2fa
      gum # https://github.com/charmbracelet/gum
      hostname # If using Alpine, the Busybox hostname is different
      htop
      imagemagick # `mogrify`
      jq # https://github.com/jqlang/jq
      jujutsu # https://github.com/jj-vcs/jj
      keepassxc # https://github.com/keepassxreboot/keepassxc
      khal # https://github.com/pimutils/khal
      killall
      less
      libiconv
      libxml2 # For xmllint
      lsof # https://github.com/lsof-org/lsof
      mise # https://github.com/jdx/mise.git
      moreutils
      neovim # https://github.com/neovim/neovim
      neovim-remote # https://github.com/mhinz/neovim-remote.git
      newsboat # https://github.com/newsboat/newsboat
      nil # https://github.com/oxalica/nil
      nix-output-monitor # https://github.com/maralorn/nix-output-monitor
      nodejs
      ollama
      patchelf
      pkg-config
      poppler # `pdftotext`
      procps # https://gitlab.com/procps-ng/procps
      pstree
      rclone # https://github.com/rclone/rclone
      ripgrep # https://github.com/BurntSushi/ripgrep
      rrsync
      rsync # https://github.com/WayneD/rsync
      rustup
      sad # https://github.com/ms-jpq/sad
      scc # https://github.com/boyter/scc
      sd # https://github.com/chmln/sd
      shfmt # https://github.com/mvdan/sh
      statix # https://github.com/oppiliappan/statix.git
      taskwarrior3 # https://github.com/GothenburgBitFactory/taskwarrior
      tldr # https://github.com/tldr-pages/tldr
      tree
      tree-sitter
      unison # https://github.com/bcpierce00/unison
      usql
      wget
      which # Arch linux 入面缺乏
      wireshark # https://gitlab.com/wireshark/wireshark
      yq # https://github.com/mikefarah/yq
      yt-dlp # https://github.com/yt-dlp/yt-dlp
      zoxide # https://github.com/ajeetdsouza/zoxide
    ]
    ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      copilot-cli # https://github.com/github/copilot-cli
      opencode # https://github.com/anomalyco/opencode
    ])
    ++ lsp-pkgs
    # 正在測試的新增內容
    ++ [
      bitwise # https://github.com/mellowcandle/bitwise
      jc # https://github.com/kellyjonbrazil/jc
      pastel # https://github.com/sharkdp/pastel
      vifm # https://vifm.info/
    ]
    ++ tmux-pkgs
    ++ (
      if env-config.has-docker
      then
        with pkgs; [
          docker
          docker-buildx
          docker-compose
        ]
      # virtualisation.docker.daemon.settings."insecure-registries" = [
      #   "192.168.X.X:5000"
      # ];
      # environment.etc."buildkitd.toml".text = ''
      #   [registry."192.168.X.X:5000"]
      #     http = true
      #     insecure = true
      # '';
      else []
    )
    ++ (
      if env-config.no-bun
      then []
      else with pkgs; [bun]
    )
    ++ (
      if env-config.has-hashi
      then
        with pkgs; [
          terraform-ls
          terraform
          vagrant
        ]
      else []
    )
    ++ (
      if env-config.no_watchman
      then []
      else
        with pkgs; [
          watchman # https://github.com/facebook/watchman
        ]
    )
    ++ (
      if is_linux
      then
        with pkgs;
          [
            ast-grep # https://ast-grep.github.io/
            dmidecode
            gnumake
            bluetuith # https://github.com/bluetuith-org/bluetuith
            iotop
            lshw
            ps_mem # https://github.com/pixelb/ps_mem
            strace
            unixtools.netstat
            xclip
          ]
          ++ (lib.optional env-config.has_cli_openvpn pkgs.update-resolv-conf)
      else []
    )
    ++ (
      if env-config.has_aws
      then
        with pkgs; [
          awscli2
          eksctl
          awsebcli
        ]
      else []
    )
    ++ (lib.optional env-config.has-shellcheck pkgs.shellcheck)
    ++ (lib.optional env-config.has-azure pkgs.azcopy)
    ++ (lib.optional env-config.has_cli_hasura pkgs.hasura-cli)
    ++ (lib.optional env-config.has_cli_openvpn pkgs.openvpn) # https://github.com/OpenVPN/openvpn
    ++ (lib.optional env-config.has-pg pkgs.postgresql)
    ++ (lib.optional env-config.has-logdy logdy)
    ++ (lib.optional env-config.has-stripe pkgs.stripe-cli) # https://github.com/stripe/stripe-cli
    ++ (lib.optional env-config.has-mssql pkgs.sqlcmd)
    ++ (lib.optional env-config.has-qemu pkgs.guestfs-tools)
    ++ (lib.optional env-config.has-qemu pkgs.qemu)
    ++ (lib.optional env-config.has-podman pkgs.podman)
    ++ (lib.optional env-config.has-iredis pkgs.iredis);
}
