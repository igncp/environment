{pkgs, ...}: {
  # 啟用 Cinnamon 桌面環境
  services.xserver.desktopManager.cinnamon.enable = true;
  services.displayManager.defaultSession = "cinnamon";
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    feh
  ];
}
