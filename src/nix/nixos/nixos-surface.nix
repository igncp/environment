{
  pkgs,
  nixos-hardware,
  ...
}: {
  imports = [
    nixos-hardware.nixosModules.microsoft-surface-go
  ];

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  powerManagement.enable = true;
  services.tlp.enable = true;

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

  hardware.microsoft-surface.kernelVersion = "stable";
}
