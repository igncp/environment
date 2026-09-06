{unstable-pkgs, ...}: {
  environment.systemPackages = [
    unstable-pkgs.tailscale
  ];

  # https://nixos.wiki/wiki/Tailscale
  services.tailscale = {
    enable = true;
    package = unstable-pkgs.tailscale;
  };
}
