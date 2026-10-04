{pkgs, ...}: {
  services.smartd = {
    enable = true;
    # "nodev0" 讓 smartd 在找不到裝置時回傳結束代碼 0，而非 17
    # （例如在 VM 上）。這對於在容器或沒有任何儲存裝置的系統執行
    # smartd 很有用。
    extraOptions = ["-q" "nodev0"];
    devices = [
      {
        # DEVICESCAN 會自動探索連接至系統的所有儲存裝置（SATA、NVMe、USB）。
        # -a      : 監控所有預設的 S.M.A.R.T. 指標（錯誤、溫度、自我測試狀態）。
        # -m <none>: 停用預設電子郵件警示路由，改將事件直接寫入 systemd 日誌。
        # 下方的持久化 systemd 計時器會處理測試排程，以便遺漏的測試在下次開機後執行。
        device = "DEVICESCAN";
        options = "-a -m <none>";
      }
    ];
  };

  # smartd 排程語法：S（短）或 L（長）/ ..（任意月份）/ ..（任意日期）/
  # .（任意星期）或 7（星期日）/ 15（15:00）。與筆記型電腦關機時會略過的
  # smartd 排程不同，持久化計時器會在下次開機後執行一次遺漏的測試。短測試
  # 不包含星期日，因為長測試已涵蓋該日，且兩種測試不能在同一裝置上同時執行。
  # 使用以下命令檢查測試結果：journalctl -u smartd
  systemd.services.smart-short-self-test = {
    description = "在偵測到的磁碟上執行短 S.M.A.R.T. 自我測試";
    serviceConfig.Type = "oneshot";
    script = ''
      while read -r device _; do
        ${pkgs.smartmontools}/bin/smartctl -t short -C "$device" || true
        echo "=== $device 的歷史日誌 ==="
        ${pkgs.smartmontools}/bin/smartctl -l selftest "$device" || true
      done < <(${pkgs.smartmontools}/bin/smartctl --scan-open)
    '';
  };

  systemd.services.smart-long-self-test = {
    description = "在偵測到的磁碟上執行長 S.M.A.R.T. 自我測試";
    serviceConfig.Type = "oneshot";
    script = ''
      while read -r device _; do
        ${pkgs.smartmontools}/bin/smartctl -t long -C "$device" || true
        echo "=== $device 的歷史日誌 ==="
        ${pkgs.smartmontools}/bin/smartctl -l selftest "$device" || true
      done < <(${pkgs.smartmontools}/bin/smartctl --scan-open)
    '';
  };

  systemd.timers.smart-short-self-test = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Mon..Sat *-*-* 15:00";
      Persistent = true;
      Unit = "smart-short-self-test.service";
    };
  };

  systemd.timers.smart-long-self-test = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sun *-*-* 15:00";
      Persistent = true;
      Unit = "smart-long-self-test.service";
    };
  };
}
