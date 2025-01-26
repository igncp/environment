# https://home-manager-options.extranix.com
{
  lib,
  pkgs,
  ...
}: let
  home_dir = builtins.getEnv "HOME";
  user = builtins.getEnv "USER";

  base_config = home_dir + "/development/environment/project/.config";
  has_gui = builtins.pathExists (base_config + "/gui");
  is_linux =
    (pkgs.system == "x86_64-linux")
    || (pkgs.system == "aarch64-linux");
  is_linux_gui = has_gui && is_linux;

  cli-pkgs = import ../common/cli.nix {inherit base_config lib pkgs;};
  php-pkgs = import ../common/php.nix {inherit base_config pkgs;};
  lua-pkgs = import ../common/lua.nix {inherit base_config pkgs;};
  java-pkgs = import ../common/java.nix {inherit base_config lib pkgs;};
in
  {
    home.username = user;
    home.homeDirectory = home_dir;
    home.stateVersion = "24.05";
    home.packages =
      []
      ++ cli-pkgs.pkgs-list
      ++ php-pkgs.pkgs-list
      ++ java-pkgs.pkgs-list
      ++ lua-pkgs.pkgs-list
      ++ (
        if is_linux_gui
        then with pkgs; [ibus rime-data ibus-engines.rime]
        else []
      );
    home.enableNixpkgsReleaseCheck = false;
    programs.home-manager.enable = true;
  }
  // (
    if has_gui && is_linux
    then {
      i18n.inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-rime
        ];
      };
    }
    else {}
  )
