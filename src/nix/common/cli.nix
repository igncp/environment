{
  base-config,
  pkgs,
  lib,
  llm-agents,
}: let
  has_cli_hasura = builtins.pathExists (base-config + "/cli-hasura");
  has_cli_openvpn = builtins.pathExists (base-config + "/cli-openvpn");
  has_hashi = builtins.pathExists (base-config + "/hashi");
  has_pg = builtins.pathExists (base-config + "/postgres");
  has_aws = builtins.pathExists (base-config + "/cli-aws");
  has_shellcheck = builtins.pathExists (base-config + "/shellcheck");
  has_azure = builtins.pathExists (base-config + "/azure");
  has_stripe = builtins.pathExists (base-config + "/stripe");
  has_podman = builtins.pathExists (base-config + "/podman");
  has_mssql = builtins.pathExists (base-config + "/mssql");
  has_qemu = builtins.pathExists (base-config + "/qemu");
  has_logdy = builtins.pathExists (base-config + "/logdy");
  has-iredis = builtins.pathExists (base-config + "/iredis");
  has-docker = builtins.pathExists (base-config + "/docker");

  no-bun = builtins.pathExists (base-config + "/no-bun"); # 在某些舊 CPU 上無法運作

  logdy = import ../derivations/logdy.nix {inherit pkgs;};

  no_watchman = builtins.pathExists (base-config + "/no-watchman");

  is_linux =
    (pkgs.system == "x86_64-linux")
    || (pkgs.system == "aarch64-linux")
    || pkgs.system == "armv7l-linux";

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
      gh-copilot # https://github.com/github/copilot-cli
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
      lsof # https://github.com/lsof-org/lsof
      mise # https://github.com/jdx/mise.git
      moreutils
      neovim # https://github.com/neovim/neovim
      neovim-remote # https://github.com/mhinz/neovim-remote.git
      newsboat # https://github.com/newsboat/newsboat
      nil # https://github.com/oxalica/nil
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
      silver-searcher # https://github.com/ggreer/the_silver_searcher
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
    ++ (with llm-agents.packages.${pkgs.system}; [
      copilot-cli
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
      if has-docker
      then
        with pkgs; [
          docker
          docker-buildx
          docker-compose
        ]
      else []
    )
    ++ (
      if no-bun
      then []
      else with pkgs; [bun]
    )
    ++ (
      if has_hashi
      then
        with pkgs; [
          terraform-ls
          terraform
          vagrant
        ]
      else []
    )
    ++ (
      if no_watchman
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
          ++ (lib.optional has_cli_openvpn pkgs.update-resolv-conf)
      else []
    )
    ++ (
      if has_aws
      then
        with pkgs; [
          awscli2
          eksctl
          awsebcli
        ]
      else []
    )
    ++ (lib.optional has_shellcheck pkgs.shellcheck)
    ++ (lib.optional has_azure pkgs.azcopy)
    ++ (lib.optional has_cli_hasura pkgs.hasura-cli)
    ++ (lib.optional has_cli_openvpn pkgs.openvpn) # https://github.com/OpenVPN/openvpn
    ++ (lib.optional has_pg pkgs.postgresql)
    ++ (lib.optional has_logdy logdy)
    ++ (lib.optional has_stripe pkgs.stripe-cli) # https://github.com/stripe/stripe-cli
    ++ (lib.optional has_mssql pkgs.sqlcmd)
    ++ (lib.optional has_qemu pkgs.guestfs-tools)
    ++ (lib.optional has_qemu pkgs.qemu)
    ++ (lib.optional has_podman pkgs.podman)
    ++ (lib.optional has-iredis pkgs.iredis);
}
