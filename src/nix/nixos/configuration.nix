{
  pkgs,
  lib,
  user,
  base-config,
  ...
}: let
  has-k3s = builtins.pathExists (base-config + "/k3s");
  has-docker = builtins.pathExists (base-config + "/docker");
  has-gui = builtins.pathExists (base-config + "/gui");
  has-android = builtins.pathExists (base-config + "/android");
  has-tailscale = builtins.pathExists (base-config + "/tailscale");
  has-n8n = builtins.pathExists (base-config + "/n8n");
  has-expressvpn = builtins.pathExists (base-config + "/expressvpn");
  has-printing = builtins.pathExists (base-config + "/printing");
  has-custom = builtins.pathExists ./custom.nix;
  emojify = import ./emojify.nix {inherit pkgs;};
in {
  imports =
    [
      ./default_pkgs.nix
      /etc/nixos/configuration.nix
      ./home-manager-entry.nix
      ./ai.nix
    ]
    ++ (lib.optional has-custom ./custom.nix)
    ++ (lib.optional has-k3s ./k3s.nix)
    ++ (lib.optional has-android ./android.nix)
    ++ (lib.optional has-tailscale ./tailscale.nix)
    ++ (lib.optional has-gui ./gui.nix);

  config = lib.mkMerge [
    {
      hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
          };
        };
      };

      services = {
        vscode-server.enable = true;
        journald.extraConfig = "SystemMaxUse=1G";
        # 呢個假設部機有加密磁碟，如果需要就改
        displayManager.autoLogin = {
          user = "${user}";
          enable = true;
        };
        blueman.enable = true;
        openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
          };
        };
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts =
            [22]
            ++ (
              if has-gui
              then [
                24800 # deskflow
              ]
              else []
            );
        };

        networkmanager.enable = true;
      };

      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;

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

      time.timeZone = "Asia/Hong_Kong";

      users.defaultUserShell = pkgs.zsh;
      users.users."${user}" = {
        isNormalUser = true;
        home = "/home/${user}";
        extraGroups = [
          "wheel"
          "docker"
          "audio"
          "video"
          "networkmanager"
        ];
        shell = pkgs.zsh;
      };

      system.stateVersion = "25.05";

      security.sudo.extraRules = [
        {
          users = ["igncp"];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemctl suspend";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];

      environment.systemPackages = with pkgs; [
        alsa-utils
        appimage-run
        cacert
        dbus
        dnsutils
        emojify
        file
        gcc
        gnupg
        lshw
        openssl
        openssl.dev
        pciutils # 包括 lspci
        ps_mem
        python3
        vnstat
      ];

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
    }
    (
      if has-printing
      then {
        environment.systemPackages = with pkgs; [
          simple-scan
        ];
        # http://localhost:631/
        # https://wiki.nixos.org/wiki/Printing
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
        services.printing = {
          enable = true;
          drivers = with pkgs; [
            cups-browsed
            cups-filters
            hplip
            hplipWithPlugin
          ];
        };
      }
      else {}
    )
    (
      if has-docker
      then {
        virtualisation.docker.enable = true;
      }
      else {}
    )
    (
      if has-n8n
      then {
        services.n8n.enable = true;
      }
      else {}
    )
    (
      if has-expressvpn
      then {
        environment.systemPackages = with pkgs; [
          expressvpn
        ];
        services.expressvpn.enable = true;
      }
      else {}
    )
  ];
}
