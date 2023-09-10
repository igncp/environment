{
  pkgs,
  lib,
  unstable,
  bun,
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

  has_hashi = builtins.pathExists (base_config + "/hashi");
  has_ruby = builtins.pathExists (base_config + "/ruby");
  has_pg = builtins.pathExists (base_config + "/postgres");

  cli-pkgs = import ./cli.nix {inherit base_config unstable_pkgs pkgs lib;};
  node-pkgs = import ./node.nix {inherit base_config pkgs lib unstable_pkgs bun;};
  go-pkgs = import ./go.nix {inherit base_config pkgs lib unstable;};
in {
  home.username = "igncp";
  home.homeDirectory = home_dir;
  home.stateVersion = "23.05";
  home.packages =
    []
    ++ cli-pkgs.pkgs-list
    ++ node-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ (lib.optional has_ruby pkgs.ruby)
    ++ (lib.optional has_hashi pkgs.terraform-ls)
    ++ (lib.optional has_hashi pkgs.vagrant)
    ++ (lib.optional has_hashi pkgs.terraform)
    ++ (lib.optional has_pg pkgs.postgresql);

  programs.home-manager.enable = true;
}
