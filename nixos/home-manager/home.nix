{
  pkgs,
  lib,
  unstable,
  ...
}: let
  unstable_pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  home_dir =
    if pkgs.system == "aarch64-darwin"
    then "/Users/igncp"
    else "/home/igncp";

  base_config = home_dir + "/development/environment/project/.config";

  is_arm_darwin = pkgs.system == "aarch64-darwin";
  has_hashi = builtins.pathExists (base_config + "/hashi");
  has_ruby = builtins.pathExists (base_config + "/ruby");
  has_pg = builtins.pathExists (base_config + "/postgres");
in {
  imports = [
    (import ./go.nix {inherit base_config;})
    (import ./node.nix {inherit base_config;})
  ];
  home.username = "igncp";
  home.homeDirectory = home_dir;
  home.stateVersion = "23.05";
  home.packages = with pkgs;
    [
      ack
      alejandra
      bat
      direnv
      duf
      fd
      fzf
      gh
      graphviz
      htop
      hurl
      jq
      mkcert
      moreutils
      ncdu
      neofetch
      neovim
      nmap
      openvpn
      pandoc
      pastel
      pkg-config
      python3
      python3.pkgs.pip
      ranger
      rsync
      scc
      silver-searcher
      speedtest-cli
      taskwarrior
      tmux
      tree
      unstable_pkgs.age
      unstable_pkgs.nil
      unzip
      watchman
      wget
      yq
      zip
      zsh
    ]
    ++ (lib.optional has_ruby pkgs.ruby)
    ++ (lib.optional has_hashi pkgs.terraform-ls)
    ++ (lib.optional has_hashi pkgs.vagrant)
    ++ (lib.optional has_hashi pkgs.terraform)
    ++ (lib.optional has_pg pkgs.postgresql)
    ++ (lib.optional has_pg pkgs.pgcli)
    ++ (lib.optional is_arm_darwin pkgs.libiconv)
    ++ (lib.optional (is_arm_darwin == false) pkgs.iotop);

  programs.home-manager.enable = true;
}
