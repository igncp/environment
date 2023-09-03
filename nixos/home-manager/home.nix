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
    (import ./cli.nix {inherit base_config unstable_pkgs;})
    (import ./go.nix {inherit base_config is_arm_darwin;})
    (import ./node.nix {inherit base_config;})
  ];
  home.username = "igncp";
  home.homeDirectory = home_dir;
  home.stateVersion = "23.05";
  home.packages = with pkgs;
    [
      moreutils
      neovim
      nmap
      openvpn
      pkg-config
      python3
      python3.pkgs.pip
      unstable_pkgs.nil
      watchman
      zsh
    ]
    ++ (lib.optional has_ruby pkgs.ruby)
    ++ (lib.optional has_hashi pkgs.terraform-ls)
    ++ (lib.optional has_hashi pkgs.vagrant)
    ++ (lib.optional has_hashi pkgs.terraform)
    ++ (lib.optional has_pg pkgs.postgresql)
    ++ (
      if is_arm_darwin
      then [pkgs.libiconv]
      else [pkgs.iotop pkgs.gnumake]
    );

  programs.home-manager.enable = true;
}
