{
  modules-list,
  nixos-raspberry,
  specialArgs,
}:
builtins.trace "運行 RP5"
(nixos-raspberry.lib.nixosSystemFull {
  modules = with nixos-raspberry.nixosModules;
    modules-list
    ++ [
      raspberry-pi-5.base
      (
        {pkgs, ...}: {
          nixpkgs.hostPlatform = "aarch64-linux";
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
})
