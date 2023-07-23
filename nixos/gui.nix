{
  config,
  lib,
  pkgs,
  modulesPath,
  unstable,
  ...
}: let
  has_i3 = builtins.pathExists ../project/.config/gui-i3;
  has_rime = builtins.pathExists ../project/.config/rime;
  has_copyq = builtins.pathExists ../project/.config/copyq;
  has_nvidia = (builtins.readFile ../project/.config/nvidia) == "yes\n";
  unstable_pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  imports =
    []
    ++ (lib.optional has_nvidia ./gui-nvidia.nix)
    ++ (lib.optional has_rime ./gui-rime.nix)
    ++ (lib.optional has_i3 ./gui-i3.nix);

  hardware.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
    acpi
    arandr
    blueberry
    dropbox
    feh
    firefox
    keepass
    realvnc-vnc-viewer
    rofi
    rpi-imager
    slack
    steam
    terminator
    unstable_pkgs.google-chrome
    variety
    xclip
    zoom-us
  ] ++ (lib.optional has_copyq copyq);

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    (nerdfonts.override {fonts = ["Monofur"];})
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.defaultSession = "cinnamon";
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

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
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
