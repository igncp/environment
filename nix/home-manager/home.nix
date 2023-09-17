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

  home_dir = builtins.getEnv "HOME";
  user = builtins.getEnv "USER";

  base_config = home_dir + "/development/environment/project/.config";

  cli-pkgs = import ../common/cli.nix {inherit base_config unstable_pkgs pkgs lib;};
  node-pkgs = import ../common/node.nix {inherit base_config pkgs lib unstable_pkgs;};
  go-pkgs = import ../common/go.nix {inherit base_config pkgs lib unstable;};
  ruby-pkgs = import ../common/ruby.nix {inherit base_config pkgs;};
in {
  home.username = user;
  home.homeDirectory = home_dir;
  home.stateVersion = "23.05";
  home.packages = with pkgs;
    [
      openssl
      openssl.dev
      # Perl was needed for rust build
      perl
    ]
    ++ cli-pkgs.pkgs-list
    ++ node-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ ruby-pkgs.pkgs-list;

  programs.home-manager.enable = true;
}
