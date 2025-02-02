# https://nixos.wiki/wiki/VirtualBox
{
  user,
  lib,
  ...
}: let
  base_config = ../../project/.config;

  has_virtualbox = builtins.pathExists (base_config + "/gui-virtualbox");
  has_virtmanager = builtins.pathExists (base_config + "/gui-virtmanager");
in
  {}
  // (
    if has_virtmanager
    then {
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = ["${user}"];
      virtualisation.libvirtd.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
    }
    else {}
  )
  // (
    if has_virtualbox
    then {
      users.extraGroups.vboxusers.members = [user];
      # virtualisation.virtualbox.guest.enable = true;
      # virtualisation.virtualbox.guest.x11 = true;
      virtualisation.virtualbox.host.enable = true;
      # virtualisation.virtualbox.host.enableExtensionPack = true; # 這需要很長時間才能安裝
    }
    else {}
  )
