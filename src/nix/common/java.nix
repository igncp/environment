{
  pkgs,
  lib,
  env-config,
}: let
  java_pkg = with pkgs;
    {
      "" = openjdk;
      "11" = openjdk11;
      "17" = openjdk17;
    }
    ."${env-config.java}";
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
