{
  pkgs,
  nixos-hardware,
  ...
}: {
  imports = [
    nixos-hardware.nixosModules.microsoft-surface-go
  ];

  environment.systemPackages = with pkgs; [
    surface-control
  ];
  services.udev.packages = [
    pkgs.iptsd
    pkgs.surface-control
  ];
  systemd.packages = [
    pkgs.iptsd
  ];
}
