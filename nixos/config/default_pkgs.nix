{
  pkgs,
  unstable,
  ...
}: let
  base_config = ../../project/.config;
  unstable_pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  emojify = import ./emojify.nix {inherit pkgs;};

  has_c = builtins.pathExists (base_config + "/c");
  has_cli_aws = builtins.pathExists (base_config + "/cli-aws");
  has_cli_gh = builtins.pathExists (base_config + "/cli-gh");
  has_cli_openvpn = builtins.pathExists (base_config + "/cli-openvpn");
  has_go = builtins.pathExists (base_config + "/go");
  has_ruby = builtins.pathExists (base_config + "/ruby");
  has_shellcheck = builtins.pathExists (base_config + "/shellcheck");
  has_tailscale = builtins.pathExists (base_config + "/tailscale");
  has_hashi = builtins.pathExists (base_config + "/hashi");
in {
  environment.systemPackages = with pkgs;
    [
      ack
      age
      alejandra
      alsa-utils
      bat
      cacert
      cachix
      dbus
      direnv
      dnsutils
      docker
      duf
      emojify
      fd
      figlet
      file
      flameshot
      gcc
      git
      gnumake
      gnupg
      graphviz
      htop
      hurl
      iotop
      jq
      libiconv
      lshw
      lsof
      mitmproxy
      mkcert
      moreutils
      ncdu
      neofetch
      neovim
      nil
      nixopsUnstable
      nmap
      nodejs
      openssl
      openvpn
      pandoc
      pastel
      pgcli
      pkgconfig
      ps_mem
      python3
      python3.pkgs.pip
      ranger
      rustup
      scc
      silver-searcher
      speedtest-cli
      sqlite
      statix
      taskwarrior
      tmux
      tree
      unstable_pkgs.nix-init # https://github.com/nix-community/nix-init
      unstable_pkgs.yt-dlp
      unzip
      valgrind
      vim
      vnstat
      wget
      yq
      zip
      zsh
    ]
    ++ (lib.optional has_cli_aws pkgs.awscli2)
    ++ (lib.optional has_cli_gh pkgs.gh)
    ++ (lib.optional has_cli_openvpn pkgs.openvpn)
    ++ (lib.optional has_go pkgs.go)
    ++ (lib.optional has_ruby pkgs.ruby)
    ++ (lib.optional has_c pkgs.clib)
    ++ (lib.optional has_c pkgs.ctags)
    ++ (lib.optional has_c pkgs.gcovr)
    ++ (lib.optional has_hashi pkgs.terraform-ls)
    ++ (lib.optional has_hashi pkgs.terraform)
    ++ (lib.optional has_hashi pkgs.vagrant)
    ++ (lib.optional has_shellcheck pkgs.shellcheck)
    ++ (lib.optional has_tailscale pkgs.tailscale);
}
