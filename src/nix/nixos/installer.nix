{
  base-config,
  lib,
  llm-agents,
  nixpkgs,
  pkgs,
  system,
}: let
  wifi-ssid = builtins.getEnv "WIFI_SSID";
  wifi-pass = builtins.getEnv "WIFI_PASS";
  root-uuid = builtins.getEnv "ROOT_UUID";
  boot-uuid = builtins.getEnv "BOOT_UUID";
  common-iso-config = {
    networking.networkmanager.enable = lib.mkForce false; # 與 `wireless.networks` 衝突
    networking.wireless.enable = true;
    networking.wireless.networks = {
      "${wifi-ssid}" = {
        psk = "${wifi-pass}";
      };
    };
    services.openssh.enable = true;
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
          // common-iso-config)
    ];
  };

  # 使用 7 吋螢幕時，預設安裝程式未能啟動，請改用呢個可開機 USB 系統。
  # 使用方法請參閱 .shell_aliases。
  iso-installer-barebones = nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      (
        {pkgs, ...}:
          assert wifi-ssid != "";
          assert wifi-pass != "";
          assert root-uuid != "";
          assert boot-uuid != ""; {
            fileSystems."/" = {
              device = "/dev/disk/by-uuid/${root-uuid}";
              fsType = "ext4";
              neededForBoot = true;
            };
            fileSystems."/boot" = {
              device = "/dev/disk/by-uuid/${boot-uuid}";
              fsType = "vfat";
            };
            boot.initrd.availableKernelModules = [
              "xhci_pci"
              "ehci_pci"
              "ahci"
              "nvme"
              "usb_storage"
              "uas"
            ];
            boot.initrd.systemd.enable = lib.mkForce true;
            boot.initrd.systemd.emergencyAccess = true;
            systemd.enableEmergencyMode = false;
            services.openssh.enable = true;
            networking.useDHCP = lib.mkForce true;
            hardware.enableRedistributableFirmware = true;
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.loader.grub.enable = lib.mkForce true;
            boot.loader.grub.efiSupport = lib.mkForce true;
            boot.loader.grub.device = lib.mkForce "nodev";
            boot.loader.grub.efiInstallAsRemovable = lib.mkForce true;
            users.users.root.initialPassword = "nixos";
            services.openssh = {
              settings = {
                PermitRootLogin = "yes";
                PasswordAuthentication = true;
              };
            };
            documentation.enable = false;
            environment.systemPackages =
              cli-pkgs.pkgs-list
              ++ (with pkgs; [
                nixos-install-tools
                util-linux # cfdisk 分割工具
                tmux
                zsh
              ]);
            services.getty.autologinUser = lib.mkForce "root";
          }
      )
    ];
  };
}
