{
  pkgs,
  lib,
  ...
}: let
  has_gui = builtins.pathExists ../../project/.config/gui;
  has_android = builtins.pathExists ../../project/.config/android;
  has_custom = builtins.pathExists ./custom.nix;
  hm_config_name = ".config/nixos-home-manager";
  has_hm = builtins.pathExists (../../project + ("/" + hm_config_name));
  tmux = import ../common/tmux.nix {inherit pkgs;};
in {
  imports =
    [
      ./default_pkgs.nix
      /etc/nixos/configuration.nix
    ]
    ++ (lib.optional has_custom ./custom.nix)
    ++ (lib.optional has_android ./android.nix)
    ++ (lib.optional has_hm ./home-manager-entry.nix)
    ++ (lib.optional has_gui ./gui.nix);

  config = {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfree = true;

    virtualisation.docker.enable = true;
    environment.variables = {
      CURL_CA_BUNDLE = "/etc/pki/tls/certs/ca-bundle.crt"; # 為 curl 添加
      OPENSSL_DEV = pkgs.openssl.dev;
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig"; # 為 rust 添加
      QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
      LD_LIBRARY_PATH_VAL = "${pkgs.stdenv.cc.cc.lib}/lib"; # 用於修復nodenv二進位文件
    };

    i18n.defaultLocale = "zh_TW.UTF-8";

    # Updates: /etc/nix/nix.conf
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    programs.zsh.enable = true;

    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "no";
    services.openssh.settings.PasswordAuthentication = false;

    time.timeZone = "Asia/Hong_Kong";

    users.defaultUserShell = pkgs.zsh;
    users.users.igncp = {
      isNormalUser = true;
      home = "/home/igncp";
      extraGroups = ["wheel" "docker" "audio" "video" "networkmanager"];
      shell = pkgs.zsh;
    };

    system.stateVersion = "23.11";

    programs.tmux = {
      clock24 = true;
      enable = true;
      extraConfig = tmux.extraConfig;
      plugins = tmux.plugins;
      terminal = "tmux-256color";
    };
  };
}
