{pkgs, ...}: {
  systemd.services.ssh-tunnel-n = let
    port-num = "9200";
    ip = "192.168.X.X";
  in {
    description = "${port-num} 嘅持續 SSH 隧道";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      User = "igncp";
      ExecStart = "${pkgs.openssh}/bin/ssh -NT -i /home/igncp/.ssh/prometheus -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -L 0.0.0.0:${port-num}:127.0.0.1:9100 igncp@${ip}";
      Restart = "always";
      RestartSec = "30s";
      ProtectSystem = "full";
      ProtectHome = "read-only";
    };
  };
}
