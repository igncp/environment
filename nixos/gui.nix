{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  has_i3 = builtins.pathExists /home/igncp/development/environment/project/.config/gui-i3;
  has_nvidia = (builtins.readFile /home/igncp/development/environment/project/.config/nvidia) == "yes\n";
in {
  imports =
    []
    ++ (lib.optional has_nvidia ./gui-nvidia.nix)
    ++ (lib.optional has_i3 ./gui-i3.nix);

  environment.systemPackages = with pkgs; [
    acpi
    arandr
    blueberry
    dropbox
    feh
    google-chrome
    keepass
    realvnc-vnc-viewer
    rofi
    slack
    steam
    terminator
    variety
    xclip
    zoom-us
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

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
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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
