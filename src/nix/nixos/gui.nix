{
  lib,
  pkgs,
  system,
  unstable-pkgs,
  ghostty,
  user,
  nixgl-pkgs,
  env-config,
  ...
}: let
  base-config = ../../../project/.config;

  has-nvidia = builtins.readFile (base-config + "/nvidia") == "yes\n";
  is-i3 = !env-config.has-cinnamon && !env-config.has-lxqt && !env-config.has-hyprland;

  common-gui = import ../common/gui.nix {
    skip-hyprland = true;
    inherit
      lib
      pkgs
      system
      unstable-pkgs
      user
      base-config
      env-config
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
      ++ (lib.optional env-config.has-lxqt ./gui-lxqt.nix)
      ++ (lib.optional has-nvidia ./gui-nvidia.nix)
      ++ (lib.optional env-config.has-cinnamon ./gui-cinnamon.nix);

    services.flatpak.enable = true;

    environment.systemPackages = common-gui.packages ++ (lib.optional env-config.has-vscode unstable-pkgs.vscode);

    fonts.packages = common-gui.fonts;

    programs.hyprland.enable = env-config.has-hyprland;

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
    if env-config.no-1password
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
    if env-config.has-hyprland
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
