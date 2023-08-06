{
  pkgs,
  lib,
  ...
}: let
  has_gui = builtins.pathExists ../project/.config/gui;
  has_android = builtins.pathExists ../project/.config/android;
  has_custom = builtins.pathExists ./custom.nix;
  hm_config_name = ".config/nix-home-manager";
  has_hm = builtins.pathExists (../project + ("/" + hm_config_name));
in {
  imports =
    [
      ./hardware-configuration.nix
      ./config/default_pkgs.nix
    ]
    ++ (lib.optional has_custom ./custom.nix)
    ++ (lib.optional has_android ./config/android.nix)
    ++ (lib.optional has_hm ./config/home-manager-entry.nix)
    ++ (lib.optional has_gui ./config/gui.nix);

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

    virtualisation.docker.enable = true;

    environment.variables = {
      CURL_CA_BUNDLE = "/etc/pki/tls/certs/ca-bundle.crt"; # Added for curl
      OPENSSL_DEV = pkgs.openssl.dev;
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig"; # Added for Rust
      QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
    };

    i18n.defaultLocale = "en_US.UTF-8";

    # Updates: /etc/nix/nix.conf
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/services/misc/nix-daemon.nix
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    programs.zsh.enable = true;

    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "yes";

    system.stateVersion = "23.05";

    time.timeZone = "Asia/Hong_Kong";

    users.defaultUserShell = pkgs.zsh;
    users.users.igncp = {
      isNormalUser = true;
      home = "/home/igncp";
      extraGroups = ["wheel" "docker" "audio" "video" "networkmanager"];
      shell = pkgs.zsh;
    };
  };
}
