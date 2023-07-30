{
  pkgs,
  lib,
  config,
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

  has_go = builtins.pathExists (base_config + "/go");
  has_hashi = builtins.pathExists (base_config + "/hashi");
  has_ruby = builtins.pathExists (base_config + "/ruby");
in {
  home.username = "igncp";
  home.homeDirectory = home_dir;
  home.stateVersion = "23.05";
  home.packages = with pkgs;
    [
      alejandra
      bat
      direnv
      duf
      fd
      gh
      htop
      hurl
      jq
      ncdu
      neofetch
      nmap
      openvpn
      pastel
      ps_mem
      ranger
      scc
      tree
      unstable_pkgs.age
      unzip
    ]
    ++ (lib.optional has_ruby pkgs.ruby)
    ++ (lib.optional has_hashi pkgs.terraform-ls)
    ++ (lib.optional has_hashi pkgs.vagrant)
    ++ (lib.optional has_hashi pkgs.terraform)
    ++ (lib.optional has_go pkgs.go);

  programs.home-manager.enable = true;
}
