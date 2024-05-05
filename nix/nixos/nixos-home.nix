{pkgs, ...}: let
  home_dir =
    if pkgs.system == "aarch64-darwin"
    then "/Users/igncp"
    else "/home/igncp";
in {
  home.username = "igncp";
  home.homeDirectory = home_dir;
  home.stateVersion = "23.11";
  home.packages = [];
  programs.home-manager.enable = true;
}
