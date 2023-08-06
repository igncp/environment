{pkgs, ...}: {
  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-...".device = "/dev/disk/by-uuid/...";
  boot.initrd.luks.devices."luks-...".keyFile = "/crypto_keyfile.bin";

  networking.extraHosts = ''
    192.168.1.50 foo
  '';
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  services.openssh.settings.PasswordAuthentication = false;
  users.users.igncp.openssh.authorizedKeys.keys = ["THE KEY HERE"];

  environment.systemPackages = [pkgs.killall];
}
