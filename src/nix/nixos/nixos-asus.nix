{...}: {
  services.libinput.touchpad.tapping = false;
  services.libinput.touchpad.middleEmulation = false;

  powerManagement.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true; # （一般省電）
  services.auto-cpufreq.enable = true; # （動態 CPU 調頻）

  boot.kernel.sysctl = {
    "vm.swappiness" = 80;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16GB
    }
  ];
}
