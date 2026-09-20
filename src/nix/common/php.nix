{
  pkgs,
  env-config,
}: let
in rec {
  pkgs-list-full = with pkgs; [
    nginx
    php
    php82Packages.composer
    wp-cli # https://github.com/wp-cli/wp-cli
  ];

  pkgs-list =
    if env-config.has-php
    then pkgs-list-full
    else [];
}
