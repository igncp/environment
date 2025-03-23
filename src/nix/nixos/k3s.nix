{...}: {
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md
  networking.firewall.allowedTCPPorts = [
    6443
  ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    "--service-node-port-range 40-32767"
  ];
}
