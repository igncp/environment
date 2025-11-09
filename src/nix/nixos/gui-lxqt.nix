{pkgs, ...}: {
  services.xserver.desktopManager.lxqt.enable = true;
  services.displayManager.defaultSession = "lxqt";
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    feh
  ];
}
