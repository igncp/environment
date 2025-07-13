{
  pkgs,
  lib,
  ...
}: let
  base_config = ../../../project/.config;

  has_minecraft = builtins.pathExists (base_config + "/gui-minecraft");
in {
  environment.systemPackages =
    []
    ++ (lib.optional has_minecraft pkgs.prismlauncher);
}
