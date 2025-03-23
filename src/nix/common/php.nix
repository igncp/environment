{
  pkgs,
  base_config,
}: let
  has_php = builtins.pathExists (base_config + "/php");
in rec {
  pkgs-list-full = with pkgs; [
    nginx
    php
    php82Packages.composer
    wp-cli # https://github.com/wp-cli/wp-cli
  ];

  pkgs-list =
    if has_php
    then pkgs-list-full
    else [];
}
