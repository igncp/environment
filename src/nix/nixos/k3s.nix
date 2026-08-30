{
  base-config,
  is-rp5,
  lib,
  ...
}: let
  has-k3s-server = builtins.pathExists (base-config + "/k3s-server");
  has-k3s-worker = builtins.pathExists (base-config + "/k3s-worker");
  has-k3s = has-k3s-server || has-k3s-worker;
in
  lib.mkIf has-k3s (lib.mkMerge [
    {
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md
      networking.firewall.allowedTCPPorts = [
        6443
      ];
      services.k3s.enable = true;
    }
    (
      if has-k3s-server
      then {
        services.k3s.role = "server";
      }
      else {
        services.k3s.role = "agent";
        # # 加入 configuration.nix
        # services.k3s = {
        #   serverAddr = "https://192.168.X.X:6443";
        #   # 伺服器上：sudo cat /var/lib/rancher/k3s/server/node-token | oscopy
        #   token = "...";
        #   extraFlags = "--node-label foo=bar --node-ip=<tailscale-ip>";
        # };
      }
    )
    (lib.mkIf is-rp5 {
      boot.kernelParams = [
        "cgroup_enable=cpuset"
        "cgroup_enable=memory"
        "cgroup_memory=1"
      ];
    })
  ])
