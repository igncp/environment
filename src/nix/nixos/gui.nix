{
  lib,
  pkgs,
  system,
  unstable-pkgs,
  ghostty,
  user,
  ...
}: let
  base-config = ../../../project/.config;

  gui-content = builtins.readFile (base-config + "/gui");

  has-copyq = builtins.pathExists (base-config + "/copyq");
  has-cinnamon = builtins.pathExists (base-config + "/gui-cinnamon");
  has-i3 = builtins.pathExists (base-config + "/gui-i3");
  has-nvidia = builtins.readFile (base-config + "/nvidia") == "yes\n";

  has_opt = infix: lib.optional (lib.strings.hasInfix infix gui-content);
in {
  imports =
    [
      ./gui-rime.nix
      ./gui-virtualization.nix
      ./gui-gaming.nix
    ]
    ++ (lib.optional has-i3 ./gui_i3.nix)
    ++ (lib.optional has-nvidia ./gui-nvidia.nix)
    ++ (lib.optional has-cinnamon ./gui-cinnamon.nix);

  services.flatpak.enable = true;

  environment.systemPackages = with pkgs;
    [
      _1password-cli
      acpi
      anki-bin
      arandr
      blueberry
      cairo
      feh
      flameshot
      gedit
      gimp
      google-chrome
      gtk4
      keepass
      libsForQt5.qt5ct
      nextcloud-client
      pavucontrol
      pdfsam-basic # https://github.com/torakiki/pdfsam # 需要將語言轉做英文
      rpi-imager # 需要暫時將用戶加入'disk'群組: `sudo usermod -aG disk $USER`
      variety
      vlc
      webcamoid

      realvnc-vnc-viewer
      tigervnc

      # Hyprland

      brightnessctl
      dunst
      hyprpaper
      libnotify # For `notify-send`
      lxqt.lxqt-sudo
      networkmanagerapplet
      playerctl
      rofi
      waybar
      wdisplays
      wev
      wl-clipboard

      # Libre Office

      unstable-pkgs.libreoffice-qt # 需要`unstable-pkgs`先可以用密碼保護嘅檔案
      hunspell

      dillo
    ]
    ++ (lib.optional has-copyq copyq)
    ++ ((has_opt "electrum") electrum)
    ++ ((has_opt "discord") discord)
    ++ ((has_opt "terminator") terminator)
    ++ ((has_opt "zoom") zoom-us)
    ++ ((has_opt "steam") steam)
    ++ ((has_opt "telegram") telegram-desktop)
    ++ ((has_opt "firefox") firefox)
    ++ ((has_opt "slack") slack)
    ++ ((has_opt "vscode") vscode)
    ++ (lib.optional (system == "x86_64-linux") ghostty.packages.x86_64-linux.default);

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    pkgs.nerd-fonts.monofur
  ];

  programs.hyprland.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
  xdg.portal.config.common.default = "*";

  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  services.logind.lidSwitch = "ignore";
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    IdleAction=suspend
    IdleActionSec=20m
  '';

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

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["${user}"];
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
