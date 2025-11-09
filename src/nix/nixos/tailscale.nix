{stable-pkgs, ...}: {
  environment.systemPackages = [
    stable-pkgs.tailscale
  ];

  # https://nixos.wiki/wiki/Tailscale
  services.tailscale = {
    enable = true;
  };
}
