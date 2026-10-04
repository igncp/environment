{
  modules-list,
  nixos-raspberry,
  specialArgs,
  disko,
  env-config,
  lib,
  llm-agents,
  nixpkgs,
  is-rp5-install,
  pkgs,
}: let
  wifi-ssid = builtins.getEnv "WIFI_SSID";
  wifi-pass = builtins.getEnv "WIFI_PASS";
  cli-pkgs = import ../common/cli.nix {
    inherit disko env-config lib llm-agents nixpkgs pkgs;
  };
in
  lib.traceIf is-rp5-install "運行 RP5 安裝設定"
  (nixos-raspberry.lib.nixosSystemFull {
    # 建構同燒錄 SD 卡：
    # sudo disko --mode disko src/nix/nixos/rp5-disko-config.nix # 請先檢查此腳本
    # IS_RP5_INSTALL=1 WIFI_SSID=... WIFI_PASS=... \
    # sudo --preserve-env nixos-install \
    #   --flake '.#rp5' --root /mnt --impure
    # 匯出已安裝系統嘅閉包，避免日後重建自訂核心同韌體：
    # system=$(readlink -f /mnt/nix/var/nix/profiles/system)
    # system=/nix/store/${system##*/}
    # sudo sh -c 'nix-store --store "local?root=/mnt" --export \
    #   $(nix-store --store "local?root=/mnt" -qR "$1") | \
    #   zstd -T0 -10 -o "$2"' sh "$system" rp5-closure.nar.zst
    # 日後安裝前，匯入閉包到建構機嘅 Nix store：
    # zstd -dc rp5-closure.nar.zst | sudo nix-store --import
    # 安裝並確認可正常開機後，可在另一部 Linux 電腦備份 SD 卡：
    # sudo dd if=/dev/mmcblk0 bs=4M status=progress conv=fsync \
    #   | zstd -T0 -19 -o rp5-nixos.img.zst
    # 還原時，目標 SD 卡嘅實際容量必須同原卡相同或更大：
    # zstd -dc rp5-nixos.img.zst \
    #   | sudo dd of=/dev/mmcblk0 bs=4M status=progress conv=fsync
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
                  networking.hostName = lib.mkForce "rp5";
                  networking.wireless.enable = true;
                  networking.wireless.networks = {
                    "${wifi-ssid}" = {
                      psk = "${wifi-pass}";
                    };
                  };
                  networking.useDHCP = true;
                  services.getty.autologinUser = lib.mkForce "root";
                  environment.systemPackages =
                    # 呢幾個會拉入 SDL，喺 RP5 建構時會失敗。
                    (builtins.filter
                      (pkg:
                        !(builtins.elem (lib.getName pkg) [
                          "cmus"
                          "fastfetch"
                          "wireshark-qt"
                        ]))
                      cli-pkgs.pkgs-list)
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
          {...}: {
            boot.initrd.availableKernelModules = ["dm-aes-ce" "dm-crypt"];
          }
        )
      ];
    specialArgs = specialArgs;
  })
