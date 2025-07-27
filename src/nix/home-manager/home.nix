# https://home-manager-options.extranix.com
{
  lib,
  pkgs,
  ...
}: let
  home_dir = builtins.getEnv "HOME";
  user = builtins.getEnv "USER";

  base-config = home_dir + "/development/environment/project/.config";
  has_gui = builtins.pathExists (base-config + "/gui");
  is_linux =
    (pkgs.system == "x86_64-linux")
    || (pkgs.system == "aarch64-linux");
  is_linux_gui = has_gui && is_linux;

  cli-pkgs = import ../common/cli.nix {inherit base-config lib pkgs;};
  ruby-pkgs = import ../common/ruby.nix {inherit base-config pkgs;};
  go-pkgs = import ../common/go.nix {inherit base-config pkgs;};
  php-pkgs = import ../common/php.nix {inherit base-config pkgs;};
  lua-pkgs = import ../common/lua.nix {inherit base-config pkgs;};
  java-pkgs = import ../common/java.nix {inherit base-config lib pkgs;};

  common-gui = import ../common/gui.nix {
    inherit lib pkgs user base-config;
    system = pkgs.system;
    unstable-pkgs = pkgs;
  };
in
  {
    home.username = user;
    home.homeDirectory = home_dir;
    home.stateVersion = "24.05";
    home.packages =
      []
      ++ (
        if (has_gui && is_linux)
        then common-gui.packages ++ common-gui.fonts ++ [pkgs.terminator]
        else []
      )
      ++ cli-pkgs.pkgs-list
      ++ php-pkgs.pkgs-list
      ++ java-pkgs.pkgs-list
      ++ lua-pkgs.pkgs-list
      ++ ruby-pkgs.pkgs-list
      ++ go-pkgs.pkgs-list;
    home.enableNixpkgsReleaseCheck = false;
    programs.home-manager.enable = true;
  }
  // (
    if has_gui && is_linux
    then {
      fonts.fontconfig.enable = true;
      i18n.inputMethod = {
        type = "fcitx5";
        enable = true;
        fcitx5.addons = with pkgs; [
          fcitx5-rime
        ];
      };
    }
    else {}
  )
