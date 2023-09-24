{
  base_config,
  unstable_pkgs,
  pkgs,
  lib,
}: let
  has_cli_aws = builtins.pathExists (base_config + "/cli-aws");
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
in {
  pkgs-list = with pkgs;
    [
      alejandra # https://github.com/kamadorueda/alejandra
      bandwhich # https://github.com/imsnif/bandwhich
      bash
      bat # https://github.com/sharkdp/bat
      btop # https://github.com/aristocratos/btop
      ctop # https://github.com/bcicen/ctop
      dasel # https://github.com/TomWright/dasel
      delta # https://github.com/dandavison/delta
      direnv # https://github.com/direnv/direnv
      doctl # https://github.com/digitalocean/doctl
      dogdns # https://github.com/ogham/dog
      du-dust # https://github.com/bootandy/dust
      duf # https://github.com/muesli/duf
      entr # https://github.com/eradman/entr
      exiftool # https://github.com/exiftool/exiftool
      fd # https://github.com/sharkdp/fd
      fzf # https://github.com/junegunn/fzf
      gh # https://github.com/cli/cli
      gnupg
      gnused
      graphviz # https://gitlab.com/graphviz/graphviz
      htop # https://github.com/htop-dev/htop
      hurl # https://github.com/Orange-OpenSource/hurl
      hyperfine # https://github.com/sharkdp/hyperfine
      iredis # https://github.com/laixintao/iredis
      jq # https://github.com/jqlang/jq
      killall
      libiconv
      lsof # https://github.com/lsof-org/lsof
      mitmproxy # https://github.com/mitmproxy/mitmproxy
      mkcert # https://github.com/FiloSottile/mkcert
      moreutils
      ncdu
      neofetch # https://github.com/dylanaraps/neofetch
      neovim # https://github.com/neovim/neovim
      nmap # https://github.com/nmap/nmap
      openvpn # https://github.com/OpenVPN/openvpn
      p7zip
      pandoc # https://github.com/jgm/pandoc
      pastel # https://github.com/sharkdp/pastel
      pgcli # https://github.com/dbcli/pgcli
      pkg-config
      procs # https://github.com/dalance/procs
      python3
      python3.pkgs.pip
      ranger # https://github.com/ranger/ranger
      rsync # https://github.com/WayneD/rsync
      sad # https://github.com/ms-jpq/sad
      scc # https://github.com/boyter/scc
      sd # https://github.com/chmln/sd
      shfmt # https://github.com/mvdan/sh
      silver-searcher # https://github.com/ggreer/the_silver_searcher
      speedtest-cli # https://github.com/sivel/speedtest-cli
      taskwarrior # https://github.com/GothenburgBitFactory/taskwarrior
      tmux # https://github.com/tmux/tmux
      tre-command # https://github.com/dduan/tre
      tree
      unstable_pkgs.age # https://github.com/FiloSottile/age
      unstable_pkgs.ast-grep # https://github.com/chmln/sd
      unstable_pkgs.bitwarden-cli # https://github.com/bitwarden/clients
      unstable_pkgs.git
      unstable_pkgs.nil # https://github.com/oxalica/nil
      unstable_pkgs.nix
      unstable_pkgs.yt-dlp # https://github.com/yt-dlp/yt-dlp
      unzip
      vim
      watchman # https://github.com/facebook/watchman
      wget
      yq # https://github.com/mikefarah/yq
      zip
      zsh
    ]
    ++ (
      if has_hashi
      then with pkgs; [terraform-ls terraform vagrant]
      else []
    )
    ++ (
      if is_linux
      then
        with pkgs; [
          lshw
          dmidecode
          iotop
          strace
          gnumake
          # If installing `gcc` in macOS, there are errors related to `-liconv`
          # when building with rust
          gcc
        ]
      else []
    )
    ++ (lib.optional has_shellcheck pkgs.shellcheck)
    ++ (lib.optional has_cli_aws pkgs.awscli2)
    ++ (lib.optional has_cli_hasura pkgs.hasura-cli)
    ++ (lib.optional has_cli_openvpn pkgs.openvpn)
    ++ (lib.optional has_pg pkgs.postgresql)
    ++ (lib.optional has_stripe pkgs.stripe-cli) # https://github.com/stripe/stripe-cli
    ++ (lib.optional has_tailscale pkgs.tailscale);
}
