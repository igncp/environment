{
  lib,
  pkgs,
  system,
  unstable_pkgs,
  ghostty,
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
      _1password
      acpi
      anki-bin
      arandr
      blueberry
      cairo
      discord
      feh
      firefox
      flameshot
      google-chrome
      gtk4
      keepass
      libsForQt5.qt5ct
      nextcloud-client
      pasystray
      pavucontrol
      pdfsam-basic # https://github.com/torakiki/pdfsam # 需要將語言轉做英文
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

      # Libre Office

      unstable_pkgs.libreoffice-qt # 需要`unstable_pkgs`先可以用密碼保護嘅檔案
      hunspell
    ]
    ++ (lib.optional has_vnc [
      realvnc-vnc-viewer
      tigervnc
    ])
    ++ (lib.optional has_copyq copyq)
    ++ (
      lib.optional (system == "x86_64-linux")
      ghostty.packages.x86_64-linux.default
    );

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

  programs.thunar.enable = true;

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

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
