{home-manager, ...}: {
  imports = [
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.igncp.imports = [./nixos-home.nix];
    }
  ];
}
