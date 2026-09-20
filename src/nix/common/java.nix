{
  pkgs,
  lib,
  base-config,
  env-config,
}: let
  java_file = base-config + "/java";

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
    ++ (lib.optional env-config.has-kotlin pkgs.kotlin)
    ++ (
      if env-config.has-java
      then [
        java_pkg
        pkgs.jdt-language-server
        pkgs.gradle
      ]
      else []
    );
}
