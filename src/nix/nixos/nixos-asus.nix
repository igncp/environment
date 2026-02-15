{pkgs, ...}: {
  services.libinput.touchpad.tapping = false;
  services.libinput.touchpad.middleEmulation = false;

  powerManagement.enable = true;
  services.thermald.enable = true;
  # TLP 同 auto-cpufreq 會衝突，只用一個
  services.auto-cpufreq.enable = true;

  services.auto-cpufreq.settings = {
    charger = {
      governor = "performance";
      turbo = "auto";
    };
    battery = {
      governor = "powersave";
      turbo = "auto";
      # 慳電模式設定
      enable_thresholds = true;
      start_threshold = 20;
      stop_threshold = 80;
    };
  };

  boot.kernel.sysctl = {
    # 低 RAM 系統，減少 swappiness 避免過度用 swap
    "vm.swappiness" = 10;
    # 優化記憶體回收
    "vm.vfs_cache_pressure" = 50;
    # 減少頁面分裂
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # 壓縮 swap 提升效能
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16GB
      # 隨機讀寫優化
      priority = 10;
    }
  ];

  # 自動清理 Nix store（30 日後刪除舊版本）
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # 優化 Nix builds
  nix.settings = {
    auto-optimise-store = true;
    # 限制並行 build，避免 RAM 爆滿
    max-jobs = 2;
    cores = 2;
  };

  # 停用不必要嘅服務
  services.xserver.displayManager.job.preStart = ''
    ${pkgs.coreutils}/bin/sleep 1
  '';
}
