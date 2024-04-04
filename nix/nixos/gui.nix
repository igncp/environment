{
  lib,
  pkgs,
  unstable,
  ...
}: let
  base_config = ../../project/.config;

  has_copyq = builtins.pathExists (base_config + "/copyq");
  has_i3 = builtins.pathExists (base_config + "/gui-i3");
  has_nvidia = builtins.readFile (base_config + "/nvidia") == "yes\n";
  has_rime = builtins.pathExists (base_config + "/rime");
  has_virtualbox = builtins.pathExists (base_config + "/gui-virtualbox");

  unstable_pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  imports =
    []
    ++ (lib.optional has_nvidia ./gui-nvidia.nix)
    ++ (lib.optional has_rime ./gui-rime.nix)
    ++ (lib.optional has_i3 ./gui-i3.nix)
    ++ (lib.optional has_virtualbox ./gui-virtualbox.nix);

  services.flatpak.enable = true;

  environment.systemPackages = with pkgs;
    [
      acpi
      arandr
      blueberry
      dropbox
      feh
      firefox
      flameshot
      keepass
      libsForQt5.qt5ct
      realvnc-vnc-viewer
      rofi
      rpi-imager
      slack
      steam
      terminator
      tigervnc
      unstable_pkgs.google-chrome
      variety
      xclip
      xdotool
      zoom-us
    ]
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

  # 啟用 Cinnamon 桌面環境
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.xserver.displayManager.defaultSession = "cinnamon";

  services.logind.lidSwitch = "ignore";

  services.xserver = {
    libinput.enable = true;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = ["igncp"];
  };
}
