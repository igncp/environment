{
  lib,
  pkgs,
  system,
  unstable-pkgs,
  ghostty,
  user,
  nixgl-pkgs,
  ...
}: let
  base-config = ../../../project/.config;

  has-cinnamon = builtins.pathExists (base-config + "/gui-cinnamon");
  has-lxqt = builtins.pathExists (base-config + "/gui-lxqt");
  has-hyprland = builtins.pathExists (base-config + "/gui-hyprland");
  no-1password = builtins.pathExists (base-config + "/gui-no-1password");
  has-nvidia = builtins.readFile (base-config + "/nvidia") == "yes\n";
  is-i3 = !has-cinnamon && !has-lxqt && !has-hyprland;
  has-vscode = builtins.pathExists (base-config + "/gui-vscode");

  common-gui = import ../common/gui.nix {
    skip-hyprland = true;
    inherit
      lib
      pkgs
      system
      unstable-pkgs
      user
      base-config
      nixgl-pkgs
      ghostty
      ;
  };
in
  {
    imports =
      [
        ./gui-rime.nix
        ./gui-virtualization.nix
      ]
      ++ (lib.optional is-i3 ./gui-i3.nix)
      ++ (lib.optional has-lxqt ./gui-lxqt.nix)
      ++ (lib.optional has-nvidia ./gui-nvidia.nix)
      ++ (lib.optional has-cinnamon ./gui-cinnamon.nix);

    services.flatpak.enable = true;

    environment.systemPackages = common-gui.packages ++ (lib.optional has-vscode unstable-pkgs.vscode);

    fonts.packages = common-gui.fonts;

    programs.hyprland.enable = has-hyprland;

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    xdg.portal.config.common.default = "*";

    services.displayManager.sddm.enable = true;

    services.logind.lidSwitch = "ignore";
    # services.logind.settings.Login = ''
    # HandlePowerKey=suspend
    # IdleAction=suspend
    # IdleActionSec=20m
    # '';

    # 螢幕鎖
    programs.xss-lock.enable = true;

    programs.thunar.enable = true;

    services.libinput.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = true;

    # 聲音的
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # 允許非免費包
    nixpkgs.config.allowUnfree = true;

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "1password-gui"
        "1password"
      ];

    programs.nm-applet.enable = true;

    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;
  }
  // (
    if no-1password
    then {}
    else {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = ["${user}"];
      };
    }
  )
  // (
    if has-hyprland
    then {
      services.displayManager.defaultSession = "hyprland";
      services.displayManager.sddm.wayland.enable = true;
    }
    else {}
  )
  // (
    if is-i3
    then {
      services.displayManager.defaultSession = "none+i3";
    }
    else {}
  )
