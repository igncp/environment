{
  ghostty,
  home-manager,
  nixgl-pkgs,
  nixos-hardware,
  nixpkgs,
  pkgs,
  stable-pkgs,
  system,
  unstable,
  vscode-server,
  nixos-raspberry,
  determinate,
}: let
  base-config = ../../../project/.config;
  has-user-file = builtins.pathExists "/etc/nixos/user"; # 用呢個指令：`sudo bash -c 'printf USER_NAME > /etc/nixos/user'`
  is-surface = builtins.pathExists (base-config + "/machine-surface");
  is-asus = builtins.pathExists (base-config + "/machine-asus");
  is-rp5 = builtins.pathExists (base-config + "/machine-rp5");
  config = {};
  hostname =
    (import /etc/nixos/configuration.nix {
      inherit pkgs config;
    })
    .networking
    .hostName;
  current-hostname = builtins.readFile "/etc/hostname";
  modules-list =
    [
      determinate.nixosModules.default
      ./configuration.nix
      vscode-server.nixosModules.default
    ]
    ++ (
      if is-surface
      then [./nixos-surface.nix]
      else []
    )
    ++ (
      if is-asus
      then [./nixos-asus.nix]
      else []
    );
  specialArgs = {
    inherit stable-pkgs home-manager system ghostty nixos-hardware base-config unstable nixgl-pkgs determinate;
    nixos-raspberrypi = nixos-raspberry;
    unstable-pkgs = pkgs;

    # 硬編碼這個值，因為它等於 nixos 中的 “root”
    user =
      if has-user-file
      then (builtins.readFile "/etc/nixos/user")
      else "igncp";
  };
  final-config = {
    "${hostname}" =
      if is-rp5 != true
      then
        (
          nixpkgs.lib.nixosSystem {
            modules = modules-list;
            specialArgs = specialArgs;
          }
        )
      else
        (builtins.trace "運行 RP5"
          (nixos-raspberry.lib.nixosSystemFull {
            modules = with nixos-raspberry.nixosModules;
              modules-list
              ++ [
                raspberry-pi-5.base
                (
                  {pkgs, ...}: {
                    fileSystems = {
                      "/boot/firmware" = {
                        device = "/dev/disk/by-label/FIRMWARE";
                        fsType = "vfat";
                        options = [
                          "noatime"
                          "noauto"
                          "x-systemd.automount"
                          "x-systemd.idle-timeout=1min"
                        ];
                      };
                      "/" = {
                        device = "/dev/disk/by-label/NIXOS_SD";
                        fsType = "ext4";
                        options = ["noatime"];
                      };
                    };
                    networking.hostName = "rp5-poe";
                  }
                )
              ];
            specialArgs = specialArgs;
          }));
  };
in
  final-config
  // (
    # 這樣做是為了能夠更改“主機名稱”。更改後需重新啟動。
    if current-hostname != hostname
    then {"${current-hostname}" = final-config."${hostname}";}
    else {}
  )
