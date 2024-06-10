{
  user,
  pkgs,
  home-manager,
  ...
}: let
  has_gui = builtins.pathExists ../../project/.config/gui;
  gui-config =
    if has_gui
    then {
      dconf.settings = {
        "org/gnome/desktop/background" = {
          picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome.gnome-themes-extra;
        };
      };
    }
    else {};
in {
  imports = [
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users."${user}" =
        {
          home.username = "${user}";
          home.homeDirectory = "/home/${user}";
          home.packages = [];
          home.stateVersion = "24.05";
          programs.home-manager.enable = true;
        }
        // gui-config;
    }
  ];
}
