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
      "11" = openjdk11;
      "17" = openjdk17;
    }
    ."${java_file_content}";
in {
  pkgs-list =
    []
    ++ (lib.optional has_kotlin pkgs.kotlin)
    ++ (
      if has_java
      then [
        java_pkg
        pkgs.jdt-language-server
        pkgs.gradle
      ]
      else []
    );
}
