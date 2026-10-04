{
  pkgs,
  nixos-hardware,
  ...
}: let
  custom-resolution-script = pkgs.writeShellScriptBin "set-low-res" ''
    #!/usr/bin/env bash
    DISPLAY=:0 ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --mode 1280x800
  '';

  custom-resolution-shortcut = pkgs.makeDesktopItem {
    name = "set-low-res-shortcut";
    desktopName = "將 Surface 顯示器設為 1280x800";
    comment = "透過 xrandr 將 eDP-1 解析度設為 1280x800";
    exec = "${custom-resolution-script}/bin/set-low-res";
    icon = "video-display";
    terminal = false;
    categories = ["Settings" "HardwareSettings"];
  };
in {
  imports = [
    nixos-hardware.nixosModules.microsoft-surface-go
    ./surface/toggle-surface-touchpad.nix
  ];

  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  powerManagement.enable = true;
  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    terminator
    mesa-demos # 用於檢查 EGL 和 OpenGL 驅動
    surface-control

    custom-resolution-script
    custom-resolution-shortcut
  ];
  services.udev.packages = [
    pkgs.iptsd
    pkgs.surface-control
  ];
  systemd.packages = [
    pkgs.iptsd
  ];

  # 修正闔上螢幕時的 CPU 問題
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    suspendKey = "ignore";
    suspendKeyLongPress = "ignore";
  };

  hardware.microsoft-surface.kernelVersion = "stable";
}
