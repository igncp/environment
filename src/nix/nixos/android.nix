# https://nixos.wiki/wiki/Android
{
  pkgs,
  user,
  ...
}: {
  programs.adb.enable = true;
  users.users."${user}".extraGroups = ["adbusers"];
  environment.variables = {
    ANDROID_HOME = "/home/${user}/Android/Sdk";
  };
  environment.systemPackages = with pkgs; [
    android-studio
  ];
}
