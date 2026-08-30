{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.tailscale
  ];

  # https://nixos.wiki/wiki/Tailscale
  services.tailscale = {
    enable = true;
    package = pkgs.tailscale;
  };
}
