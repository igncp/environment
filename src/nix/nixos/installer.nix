{
  base-config,
  lib,
  llm-agents,
  nixpkgs,
  pkgs,
  system,
  disko,
}: let
  wifi-ssid = builtins.getEnv "WIFI_SSID";
  wifi-pass = builtins.getEnv "WIFI_PASS";

  common-iso-config = {
    networking.networkmanager.enable = lib.mkForce false; # 與 `wireless.networks` 衝突
    networking.wireless.enable = true;
    networking.wireless.networks = {
      "${wifi-ssid}" = {
        psk = "${wifi-pass}";
      };
    };
    networking.useDHCP = true;
    hardware.enableRedistributableFirmware = true;
  };
  cli-pkgs = import ../common/cli.nix {
    inherit base-config lib llm-agents pkgs;
  };
in {
  # 呢個只可以喺 Linux 運行。可以建構其他架構。
  # 喺 macOS 上下載官方安裝 ISO，然後用 `dd`。
  iso-installer = nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ({pkgs, ...}:
        assert wifi-ssid != "";
        assert wifi-pass != "";
          lib.mkMerge [
            {
              environment.systemPackages = with pkgs; [
                git
                neovim
                htop
              ];
              isoImage.contents = [
                {
                  source = ./../../..;
                  target = "/environment";
                }
              ];
              users.users.nixos.password = "nixos";
            }
            common-iso-config
          ])
    ];
  };

  # 使用 7 吋螢幕時，預設安裝程式未能啟動，請改用呢個可開機 USB 系統。
  # 使用方法請參閱 .shell_aliases。
  # WIFI_SSID=... WIFI_PASS=... \
  #   sudo --preserve-env=WIFI_SSID,WIFI_PASS \
  #   nix run 'github:nix-community/disko/latest#disko-install' -- \
  #   --option pure-eval false --flake '.#iso-installer-barebones' \
  #   --disk usb /dev/sdX
  # 檢查：src/nix/nixos/templates/fresh-install-configuration.nix
  iso-installer-barebones = nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      disko.nixosModules.disko
      (
        {pkgs, ...}:
          assert wifi-ssid != "";
          assert wifi-pass != "";
            lib.mkMerge [
              {
                disko.devices = {
                  disk = {
                    usb = {
                      type = "disk";
                      device = "/dev/sdX";
                      content = {
                        type = "gpt";
                        partitions = {
                          ESP = {
                            size = "1000M";
                            type = "EF00";
                            content = {
                              type = "filesystem";
                              format = "vfat";
                              mountpoint = "/boot";
                              mountOptions = ["umask=0077"];
                            };
                          };
                          luks = {
                            size = "100%";
                            content = {
                              type = "luks";
                              name = "crypt_usb";
                              settings.allowDiscards = true;
                              content = {
                                type = "filesystem";
                                format = "ext4";
                                mountpoint = "/";
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              }
              {
                networking.useDHCP = lib.mkForce true;
                hardware.enableRedistributableFirmware = true;
                nix.settings.experimental-features = ["nix-command" "flakes"];
                boot.initrd.availableKernelModules = [
                  "xhci_pci"
                  "usb_storage"
                  "uas"
                  "sd_mod"
                ];
                boot.loader.grub.enable = lib.mkForce false;
                boot.loader.systemd-boot.enable = lib.mkForce true;
                boot.loader.efi.canTouchEfiVariables = true;
                users.users.root.initialPassword = "nixos";
                services.openssh = {
                  enable = true;
                  settings = {
                    PermitRootLogin = "yes";
                    PasswordAuthentication = true;
                  };
                };
                documentation.enable = false;
                environment.systemPackages =
                  cli-pkgs.pkgs-list
                  ++ (with pkgs; [
                    git
                    nixos-install-tools
                    util-linux # cfdisk 分割工具
                    tmux
                    zsh
                  ]);
                services.getty.autologinUser = lib.mkForce "root";
              }
              common-iso-config
            ]
      )
    ];
  };
}
