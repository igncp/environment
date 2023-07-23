# https://nixos.wiki/wiki/Android
{
  config,
  lib,
  pkgs,
  modulesPath,
  unstable,
  ...
}: {
  programs.adb.enable = true;
  users.users.igncp.extraGroups = ["adbusers"];
  environment.systemPackages = with pkgs; [
    android-studio
  ];
}
