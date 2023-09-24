{
  pkgs,
  lib,
  base_config,
}: let
  has_java = builtins.pathExists (base_config + "/java");
  has_kotlin = builtins.pathExists (base_config + "/kotlin");
in {
  pkgs-list =
    []
    ++ (lib.optional has_kotlin pkgs.kotlin)
    ++ (lib.optional has_java pkgs.openjdk);
}
