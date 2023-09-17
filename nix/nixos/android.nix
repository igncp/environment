# https://nixos.wiki/wiki/Android
{pkgs, ...}: {
  programs.adb.enable = true;
  users.users.igncp.extraGroups = ["adbusers"];
  environment.variables = {
    ANDROID_HOME = "/home/igncp/Android/Sdk";
  };
  environment.systemPackages = with pkgs; [
    android-studio
  ];
}
