{
  base_config,
  pkgs,
  lib,
}: let
  has_cli_hasura = builtins.pathExists (base_config + "/cli-hasura");
  has_cli_openvpn = builtins.pathExists (base_config + "/cli-openvpn");
  has_hashi = builtins.pathExists (base_config + "/hashi");
  has_pg = builtins.pathExists (base_config + "/postgres");
  has_aws = builtins.pathExists (base_config + "/cli-aws");
  has_shellcheck = builtins.pathExists (base_config + "/shellcheck");
  has_azure = builtins.pathExists (base_config + "/azure");
  has_stripe = builtins.pathExists (base_config + "/stripe");
  has_tailscale = builtins.pathExists (base_config + "/tailscale");
  has_podman = builtins.pathExists (base_config + "/podman");
  has_mssql = builtins.pathExists (base_config + "/mssql");
  has_qemu = builtins.pathExists (base_config + "/qemu");
  has_logdy = builtins.pathExists (base_config + "/logdy");

  logdy = import ../derivations/logdy.nix {inherit pkgs;};

  no_watchman = builtins.pathExists (base_config + "/no-watchman");

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
      act # https://github.com/nektos/act
      age # https://github.com/FiloSottile/age
      alejandra # https://github.com/kamadorueda/alejandra
      bash
      bat # https://github.com/sharkdp/bat
      bc
      ccls # https://github.com/MaskRay/ccls
      coreutils-full
      curl
      d2 # https://github.com/terrastruct/d2
      direnv # https://github.com/direnv/direnv
      docker
      docker-buildx
      docker-compose
      dua # https://github.com/Byron/dua-cli
      entr # https://github.com/eradman/entr
      fastfetch # https://github.com/fastfetch-cli/fastfetch
      fd # https://github.com/sharkdp/fd
      fzf # https://github.com/junegunn/fzf
      gh # https://github.com/cli/cli
      git
      git-extras
      git-lfs
      gnugrep
      gnupg
      gnused
      go-2fa
      hostname # If using Alpine, the Busybox hostname is different
      htop
      jq # https://github.com/jqlang/jq
      killall
      less
      libiconv
      lsof # https://github.com/lsof-org/lsof
      moreutils
      neovim # https://github.com/neovim/neovim
      neovim-remote # https://github.com/mhinz/neovim-remote.git
      nil # https://github.com/oxalica/nil
      nix
      ollama
      patchelf
      pkg-config
      procps # https://gitlab.com/procps-ng/procps
      pstree
      ripgrep # https://github.com/BurntSushi/ripgrep
      rrsync
      rsync # https://github.com/WayneD/rsync
      sad # https://github.com/ms-jpq/sad
      scc # https://github.com/boyter/scc
      sd # https://github.com/chmln/sd
      shfmt # https://github.com/mvdan/sh
      silver-searcher # https://github.com/ggreer/the_silver_searcher
      taskwarrior3 # https://github.com/GothenburgBitFactory/taskwarrior
      tree
      usql
      wget
      which # Arch linux 入面缺乏
      yq # https://github.com/mikefarah/yq
      yt-dlp # https://github.com/yt-dlp/yt-dlp
    ]
    ++ lsp-pkgs
    # 正在測試的新增內容
    ++ [
      bitwise # https://github.com/mellowcandle/bitwise
      jc # https://github.com/kellyjonbrazil/jc
      loop # https://github.com/Miserlou/Loop
      pastel # https://github.com/sharkdp/pastel
      vifm # https://vifm.info/
    ]
    ++ tmux-pkgs
    ++ (
      if has_hashi
      then with pkgs; [terraform-ls terraform vagrant]
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
      then with pkgs; [awscli2 eksctl awsebcli]
      else []
    )
    ++ (lib.optional has_shellcheck pkgs.shellcheck)
    ++ (lib.optional has_azure pkgs.azcopy)
    ++ (lib.optional has_cli_hasura pkgs.hasura-cli)
    ++ (lib.optional has_cli_openvpn pkgs.openvpn) # https://github.com/OpenVPN/openvpn
    ++ (lib.optional has_pg pkgs.postgresql)
    ++ (lib.optional has_logdy logdy)
    ++ (lib.optional has_stripe pkgs.stripe-cli) # https://github.com/stripe/stripe-cli
    ++ (lib.optional has_tailscale pkgs.tailscale)
    ++ (lib.optional has_mssql pkgs.sqlcmd)
    ++ (lib.optional has_qemu pkgs.guestfs-tools)
    ++ (lib.optional has_podman pkgs.podman);
}
