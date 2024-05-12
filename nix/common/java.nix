{
  pkgs,
  lib,
  base_config,
}: let
  java_file = base_config + "/java";

  has_java = builtins.pathExists java_file;
  has_kotlin = builtins.pathExists (base_config + "/kotlin");

  java_file_content = builtins.readFile java_file;
  java_pkg = with pkgs;
    {
      "" = openjdk;
      "11\n" = openjdk11;
    }
    ."${java_file_content}";
in {
  pkgs-list =
    []
    ++ (lib.optional has_kotlin pkgs.kotlin)
    ++ (lib.optional has_java java_pkg);
}
