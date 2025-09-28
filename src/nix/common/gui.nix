{
  lib,
  pkgs,
  system,
  unstable-pkgs,
  base-config,
  nixgl-pkgs,
  ghostty,
  skip-hyprland ? false,
  ...
}: let
  gui-content = builtins.readFile (base-config + "/gui");
  has-vscode = builtins.pathExists (base-config + "/gui-vscode");
  has-minecraft = builtins.pathExists (base-config + "/gui-minecraft");

  has-gui-opt = infix: lib.optional (lib.strings.hasInfix infix gui-content);

  gui-hyprland = with pkgs; [
    # Hyprland

    hyprland
  ];
in {
  packages = with pkgs;
    [
      _1password-cli
      acpi
      arandr
      blueberry
      cairo
      feh
      flameshot
      gedit
      gimp
      gtk4
      libsForQt5.qt5ct
      lxappearance
      nextcloud-client
      nixgl-pkgs.auto.nixGLDefault
      pavucontrol
      rofi # bash -c '. $HOME/.nix-profile/etc/profile.d/nix.sh &&  $HOME/.nix-profile/bin/nixGL $HOME/.nix-profile/bin/rofi -show combi -font "hack 20" -combi-modi drun,window,ssh'
      rpi-imager # 需要暫時將用戶加入'disk'群組: `sudo usermod -aG disk $USER`
      variety
      vlc
      webcamoid

      tigervnc

      # Libre Office

      unstable-pkgs.libreoffice-qt # 需要`unstable-pkgs`先可以用密碼保護嘅檔案
      hunspell

      dillo

      adw-gtk3
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
    ]
    ++ (
      if skip-hyprland
      then []
      else gui-hyprland
    )
    ++ ((has-gui-opt "copyq") copyq)
    ++ ((has-gui-opt "terminator") terminator)
    ++ ((has-gui-opt "zoom") zoom-us)
    ++ ((has-gui-opt "telegram") telegram-desktop)
    ++ ((has-gui-opt "firefox") firefox)
    ++ (lib.optional (system == "x86_64-linux") ghostty.packages.x86_64-linux.default)
    ++ (lib.optional has-vscode vscode)
    ++ (lib.optional has-minecraft prismlauncher)
    ++ (
      if (system == "x86_64-linux")
      then
        (
          [
            anki-bin
            google-chrome
            pdfsam-basic # https://github.com/torakiki/pdfsam # 需要將語言轉做英文
            realvnc-vnc-viewer
          ]
          ++ ((has-gui-opt "discord") discord)
          ++ ((has-gui-opt "steam") steam)
          ++ ((has-gui-opt "electrum") electrum)
          ++ ((has-gui-opt "slack") slack)
        )
      else if (system == "aarch64-linux")
      then [chromium]
      else []
    );

  fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    pkgs.nerd-fonts.monofur
  ];
}
