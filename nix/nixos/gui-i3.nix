{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    feh
    lxappearance
    lxqt.lxqt-sudo
    pasystray
    picom
    rofi
  ];

  # 啟用 X11 視窗系統。
  services.xserver.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3status
      i3lock
      i3blocks
    ];
  };
}
