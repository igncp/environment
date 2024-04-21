# https://nixos.wiki/wiki/VirtualBox
{...}: {
  users.extraGroups.vboxusers.members = ["igncp"];
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.x11 = true;
  virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true; # 這需要很長時間才能安裝
}
