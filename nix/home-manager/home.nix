{
  lib,
  pkgs,
  ...
}: let
  home_dir = builtins.getEnv "HOME";
  user = builtins.getEnv "USER";

  base_config = home_dir + "/development/environment/project/.config";

  cli-pkgs = import ../common/cli.nix {inherit base_config lib pkgs;};
  node-pkgs = import ../common/node.nix {inherit base_config lib pkgs;};
  go-pkgs = import ../common/go.nix {inherit base_config lib pkgs;};
  php-pkgs = import ../common/php.nix {inherit base_config pkgs;};
  ruby-pkgs = import ../common/ruby.nix {inherit base_config pkgs;};
  java-pkgs = import ../common/java.nix {inherit base_config lib pkgs;};
in {
  home.username = user;
  home.homeDirectory = home_dir;
  home.stateVersion = "24.05";
  home.packages =
    []
    ++ cli-pkgs.pkgs-list
    ++ node-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ php-pkgs.pkgs-list
    ++ java-pkgs.pkgs-list
    ++ ruby-pkgs.pkgs-list;
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;
}
