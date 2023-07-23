{pkgs, ...}: let
  base_config = ../project/.config;

  has_c = builtins.pathExists (base_config + "/c");
  has_cli_aws = builtins.pathExists (base_config + "/cli-aws");
  has_cli_gh = builtins.pathExists (base_config + "/cli-gh");
  has_cli_openvpn = builtins.pathExists (base_config + "/cli-openvpn");
  has_go = builtins.pathExists (base_config + "/go");
  has_ruby = builtins.pathExists (base_config + "/ruby");
  has_tailscale = builtins.pathExists (base_config + "/tailscale");
in {
  default_pkgs = with pkgs;
    [
      ack
      age
      alejandra
      alsa-utils
      bat
      cacert
      dbus
      diesel-cli
      direnv
      dnsutils
      docker
      figlet
      flameshot
      gcc
      git
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
      moreutils
      ncdu
      neofetch
      neovim
      nixopsUnstable
      nmap
      nodejs
      openssl
      openvpn
      pandoc
      pkgconfig
      python3
      python3.pkgs.pip
      ranger
      rustup
      silver-searcher
      speedtest-cli
      sqlite
      statix
      taskwarrior
      tmux
      tree
      unzip
      valgrind
      vim
      vnstat
      wasm-pack
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
    ++ (lib.optional has_tailscale pkgs.tailscale);
}
