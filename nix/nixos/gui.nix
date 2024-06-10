{
  lib,
  pkgs,
  ...
}: let
  base_config = ../../project/.config;

  has_copyq = builtins.pathExists (base_config + "/copyq");
  has_cinnammon = builtins.pathExists (base_config + "/gui-cinnammon");
  has_nvidia = builtins.readFile (base_config + "/nvidia") == "yes\n";
  has_virtualbox = builtins.pathExists (base_config + "/gui-virtualbox");
  has_vnc = builtins.pathExists (base_config + "/vnc");
in {
  imports =
    [./gui-rime.nix]
    ++ (lib.optional has_nvidia ./gui-nvidia.nix)
    ++ (lib.optional has_cinnammon ./gui-cinnammon.nix)
    ++ (lib.optional has_virtualbox ./gui-virtualbox.nix);

  services.flatpak.enable = true;

  environment.systemPackages = with pkgs;
    [
      acpi
      anki-bin
      arandr
      blueberry
      dropbox
      feh
      firefox
      flameshot
      google-chrome
      gtk4
      cairo
      keepass
      libsForQt5.qt5ct
      pavucontrol
      rpi-imager
      slack
      steam
      terminator
      variety
      vlc
      xclip
      xdotool
      zoom-us

      # I3

      lxappearance
      lxqt.lxqt-sudo
      picom
      rofi
    ]
    ++ (lib.optional has_vnc [
      realvnc-vnc-viewer
      tigervnc
    ])
    ++ (lib.optional has_copyq copyq);

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    (nerdfonts.override {fonts = ["Monofur"];})
  ];

  # 啟用 X11 視窗系統。
  services.xserver.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3status
      i3lock
      i3blocks
    ];
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
  xdg.portal.config.common.default = "*";

  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "none+i3";

  services.logind.lidSwitch = "ignore";
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    IdleAction=suspend
    IdleActionSec=20m
  '';

  # 螢幕鎖
  programs.xss-lock.enable = true;

  services.libinput.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # 聲音的
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 允許非免費包
  nixpkgs.config.allowUnfree = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # 某些功能，包括 CLI 整合和系統身份驗證支持，需要在某些桌面環境（例如
    # Plasma）上啟用 PolKit 整合。
    polkitPolicyOwners = ["igncp"];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
