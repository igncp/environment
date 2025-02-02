{
  pkgs,
  lib,
  user,
  ...
}: let
  has_gui = builtins.pathExists ../../project/.config/gui;
  has_android = builtins.pathExists ../../project/.config/android;
  has_custom = builtins.pathExists ./custom.nix;
in {
  imports =
    [
      ./default_pkgs.nix
      /etc/nixos/configuration.nix
      ./home-manager-entry.nix
    ]
    ++ (lib.optional has_custom ./custom.nix)
    ++ (lib.optional has_android ./android.nix)
    ++ (lib.optional has_gui ./gui.nix);

  config = {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [22];

    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfree = true;

    programs.nm-applet.enable = true;

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

    services.blueman.enable = true;
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;
    services.openssh.settings.PermitRootLogin = "no";

    time.timeZone = "Asia/Hong_Kong";

    # 呢個假設部機有加密磁碟，如果需要就改
    services.displayManager.autoLogin.user = "${user}";
    services.displayManager.autoLogin.enable = true;

    users.defaultUserShell = pkgs.zsh;
    users.users."${user}" = {
      isNormalUser = true;
      home = "/home/${user}";
      extraGroups = ["wheel" "docker" "audio" "video" "networkmanager"];
      shell = pkgs.zsh;
    };

    system.stateVersion = "24.11";

    services.journald.extraConfig = "SystemMaxUse=1G";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_HK.UTF-8";
      LC_IDENTIFICATION = "en_HK.UTF-8";
      LC_MEASUREMENT = "en_HK.UTF-8";
      LC_MONETARY = "en_HK.UTF-8";
      LC_NAME = "en_HK.UTF-8";
      LC_NUMERIC = "en_HK.UTF-8";
      LC_PAPER = "en_HK.UTF-8";
      LC_TELEPHONE = "en_HK.UTF-8";
      LC_TIME = "en_HK.UTF-8";
    };
  };
}
