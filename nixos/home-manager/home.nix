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

  is_darwin = pkgs.system == "aarch64-darwin";
  has_go = builtins.pathExists (base_config + "/go");
  has_hashi = builtins.pathExists (base_config + "/hashi");
  has_nix_node = builtins.pathExists (base_config + "/nix-node");
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
      mkcert
      ncdu
      neofetch
      neovim
      nmap
      openvpn
      pastel
      ranger
      rustup
      scc
      tree
      unstable_pkgs.nil
      unstable_pkgs.age
      unzip
    ]
    ++ (lib.optional has_ruby pkgs.ruby)
    ++ (lib.optional has_nix_node pkgs.nodejs)
    ++ (lib.optional has_hashi pkgs.terraform-ls)
    ++ (lib.optional has_hashi pkgs.vagrant)
    ++ (lib.optional has_hashi pkgs.terraform)
    ++ (lib.optional has_go pkgs.go)
    ++ (lib.optional is_darwin libiconv);

  programs.home-manager.enable = true;
}
