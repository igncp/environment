{
  modules-list,
  nixos-raspberry,
  specialArgs,
  disko,
  base-config,
  lib,
  llm-agents,
  is-rp5-install,
  pkgs,
}: let
  wifi-ssid = builtins.getEnv "WIFI_SSID";
  wifi-pass = builtins.getEnv "WIFI_PASS";
  cli-pkgs = import ../common/cli.nix {
    inherit base-config lib llm-agents pkgs;
  };
in
  builtins.trace "運行 RP5"
  (nixos-raspberry.lib.nixosSystemFull {
    # 建構同燒錄 SD 卡：
    # sudo nix run github:nix-community/disko -- \
    #   --mode disko src/nix/nixos/rp5-disko-config.nix # 請先檢查此腳本
    # IS_RP5_INSTALL=1 WIFI_SSID=... WIFI_PASS=... \
    # sudo --preserve-env nixos-install \
    #   --flake '.#rp5' --root /mnt --impure
    modules = with nixos-raspberry.nixosModules;
      modules-list
      ++ [
        disko.nixosModules.disko
        ./rp5-disko-config.nix
        raspberry-pi-5.base
        (
          if is-rp5-install
          then
            (
              {lib, ...}:
                assert wifi-ssid != "";
                assert wifi-pass != ""; {
                  services.openssh = {
                    enable = true;
                    settings = {
                      PermitRootLogin = lib.mkForce "yes";
                      PasswordAuthentication = lib.mkForce true;
                    };
                  };
                  networking.networkmanager.enable = lib.mkForce false; # 與 `wireless.networks` 衝突
                  networking.wireless.enable = true;
                  networking.wireless.networks = {
                    "${wifi-ssid}" = {
                      psk = "${wifi-pass}";
                    };
                  };
                  networking.useDHCP = true;
                  services.getty.autologinUser = lib.mkForce "root";
                  environment.systemPackages =
                    cli-pkgs.pkgs-list
                    ++ (with pkgs; [
                      git
                      nixos-install-tools
                      util-linux # cfdisk 分割工具
                      tmux
                      zsh
                    ]);
                }
            )
          else
            ({...}: {
              zramSwap = {
                enable = true;
                algorithm = "zstd";
                memoryPercent = 50;
              };
              swapDevices = [
                {
                  device = "/var/lib/swapfile";
                  size = 8192;
                }
              ];
            })
        )
        (
          {lib, ...}: {
            networking.hostName = lib.mkForce "rp5";
            boot.initrd.availableKernelModules = ["dm-aes-ce" "dm-crypt"];
          }
        )
      ];
    specialArgs = specialArgs;
  })
