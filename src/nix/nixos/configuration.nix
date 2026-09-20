{
  config,
  pkgs,
  lib,
  user,
  base-config,
  env-config,
  is-rp5,
  is-rp5-install,
  ...
}: let
  has-custom = builtins.pathExists ./custom.nix;
  emojify = import ./emojify.nix {inherit pkgs;};
in {
  imports = lib.optionals (!is-rp5-install) (
    [
      ./default_pkgs.nix
      /etc/nixos/configuration.nix
      ./ai.nix
      ./usb-security-luks.nix
      ./usb-security-pam.nix
      ./k3s.nix
      ./blocky.nix
      (import ./kodi.nix {inherit base-config config env-config is-rp5 lib;})
    ]
    ++ (lib.optional has-custom ./custom.nix)
    ++ (lib.optional (!is-rp5) ./home-manager-entry.nix)
    ++ (lib.optional env-config.has-android ./android.nix)
    ++ (lib.optional env-config.has-tailscale ./tailscale.nix)
    ++ (lib.optional env-config.has-gui ./gui.nix)
  );

  config = lib.mkMerge [
    {
      boot.loader.timeout = 2;

      hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
          };
        };
      };

      services = {
        journald.extraConfig = "SystemMaxUse=1G";
        # 呢個假設部機有加密磁碟，如果需要就改
        displayManager.autoLogin = {
          user = "${user}";
          enable = true;
        };
        blueman.enable = true;
        prometheus.exporters.node = {
          enable = true;
          enabledCollectors = ["systemd" "processes" "ethtool"];
        };
        # 可選：
        # networking.firewall.allowedTCPPorts = [9100];
        # networking.firewall.trustedInterfaces = [
        #   "tailscale0"
        #   "cni0"
        #   "flannel.1"
        # ];
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
              if env-config.has-gui
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
      nix.channel.enable = false;
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';

      programs.zsh.enable = true;
      # 允許 NixOS 執行通用動態連結二進位檔案，例如 wasm-pack 下載的 wasm-bindgen CLI。
      programs.nix-ld.enable = true;

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

      system.stateVersion = "26.05";

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

      environment.systemPackages =
        lib.optional (!is-rp5) pkgs.alsa-utils
        ++ (with pkgs; [
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
        ]);

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
    (lib.mkIf (!is-rp5) {
      boot.loader.systemd-boot.enable = true;
    })
    (
      if env-config.has-printing
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
      if env-config.has-docker
      then {
        virtualisation.docker.enable = true;
        users.users."${user}".extraGroups = ["docker"];
      }
      else {}
    )
    (
      if env-config.has-n8n
      then {
        services.n8n.enable = true;
      }
      else {}
    )
    (
      if env-config.has-expressvpn
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
