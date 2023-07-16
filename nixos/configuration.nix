{
  pkgs,
  lib,
  config,
  ...
}: let
  has_gui = builtins.pathExists /home/igncp/development/environment/project/.config/gui;
  has_private = builtins.pathExists ./private.nix;
  has_custom = builtins.pathExists ./custom.nix;
in {
  imports =
    [
      ./hardware-configuration.nix
    ]
    ++ (lib.optional has_custom ./custom.nix)
    ++ (lib.optional has_private ./private.nix)
    ++ (lib.optional has_gui ./gui.nix);

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    environment.systemPackages =
      (import ./default_pkgs.nix pkgs).default_pkgs;

    environment.variables = {
      CURL_CA_BUNDLE = "/etc/pki/tls/certs/ca-bundle.crt"; # Added for curl
      OPENSSL_DEV = pkgs.openssl.dev;
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig"; # Added for Rust
    };

    i18n.defaultLocale = "en_HK.UTF-8";

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
      extraGroups = ["wheel" "networkmanager"];
      shell = pkgs.zsh;
    };
  };
}
