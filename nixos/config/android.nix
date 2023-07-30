# https://nixos.wiki/wiki/Android
{pkgs, ...}: {
  programs.adb.enable = true;
  users.users.igncp.extraGroups = ["adbusers"];
  environment.systemPackages = with pkgs; [
    android-studio
  ];
}
