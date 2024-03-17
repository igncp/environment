{
  base_config,
  unstable_pkgs,
  pkgs,
  lib,
}: let
  has_cli_hasura = builtins.pathExists (base_config + "/cli-hasura");
  has_cli_openvpn = builtins.pathExists (base_config + "/cli-openvpn");
  has_hashi = builtins.pathExists (base_config + "/hashi");
  has_pg = builtins.pathExists (base_config + "/postgres");
  has_shellcheck = builtins.pathExists (base_config + "/shellcheck");
  has_stripe = builtins.pathExists (base_config + "/stripe");
  has_tailscale = builtins.pathExists (base_config + "/tailscale");

  is_linux =
    (pkgs.system == "x86_64-linux")
    || (pkgs.system == "aarch64-linux")
    || pkgs.system == "armv7l-linux";

  tmux-pkgs = with pkgs; [
    tmux # https://github.com/tmux/tmux
  ];
in {
  pkgs-list = with pkgs;
    [
      alejandra # https://github.com/kamadorueda/alejandra
      bash
      bat # https://github.com/sharkdp/bat
      coreutils-full
      curl
      delta # https://github.com/dandavison/delta
      direnv # https://github.com/direnv/direnv
      docker
      docker-buildx
      docker-compose
      dua # https://github.com/Byron/dua-cli
      fd # https://github.com/sharkdp/fd
      fzf # https://github.com/junegunn/fzf
      gh # https://github.com/cli/cli
      gnugrep
      gnupg
      gnused
      hostname # If using Alpine, the Busybox hostname is different
      htop # https://github.com/htop-dev/htop
      jq # https://github.com/jqlang/jq
      killall
      less
      libiconv
      lsof # https://github.com/lsof-org/lsof
      moreutils
      neofetch # https://github.com/dylanaraps/neofetch
      neovim-remote # https://github.com/mhinz/neovim-remote.git
      pkg-config
      podman
      pstree
      rsync # https://github.com/WayneD/rsync
      sad # https://github.com/ms-jpq/sad
      scc # https://github.com/boyter/scc
      sd # https://github.com/chmln/sd
      shfmt # https://github.com/mvdan/sh
      silver-searcher # https://github.com/ggreer/the_silver_searcher
      taskwarrior # https://github.com/GothenburgBitFactory/taskwarrior
      tree
      unstable_pkgs.age # https://github.com/FiloSottile/age
      unstable_pkgs.git
      unstable_pkgs.git-extras
      unstable_pkgs.neovim # https://github.com/neovim/neovim
      unstable_pkgs.nil # https://github.com/oxalica/nil
      unstable_pkgs.nix
      unstable_pkgs.yt-dlp # https://github.com/yt-dlp/yt-dlp
      watchman # https://github.com/facebook/watchman
      wget
      yq # https://github.com/mikefarah/yq
      zsh
    ]
    # 正在測試的新增內容
    ++ [
      bitwise # https://github.com/mellowcandle/bitwise
      jc # https://github.com/kellyjonbrazil/jc
      loop # https://github.com/Miserlou/Loop
      pastel # https://github.com/sharkdp/pastel
      vifm
    ]
    ++ tmux-pkgs
    ++ (
      if has_hashi
      then with pkgs; [terraform-ls terraform vagrant]
      else []
    )
    ++ (
      if is_linux
      then
        with pkgs;
          [
            dmidecode
            gnumake
            iotop
            lshw
            strace
            unstable_pkgs.ast-grep # https://ast-grep.github.io/
          ]
          ++ (lib.optional has_cli_openvpn pkgs.update-resolv-conf)
      else []
    )
    ++ (lib.optional has_shellcheck pkgs.shellcheck)
    ++ (lib.optional has_cli_hasura pkgs.hasura-cli)
    ++ (lib.optional has_cli_openvpn pkgs.openvpn) # https://github.com/OpenVPN/openvpn
    ++ (lib.optional has_pg pkgs.postgresql)
    ++ (lib.optional has_stripe pkgs.stripe-cli) # https://github.com/stripe/stripe-cli
    ++ (lib.optional has_tailscale pkgs.tailscale);
}
