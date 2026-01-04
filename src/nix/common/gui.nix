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
  has-minecraft = builtins.pathExists (base-config + "/gui-minecraft");

  has-gui-opt = infix: lib.optional (lib.strings.hasInfix infix gui-content);
in {
  packages = with pkgs;
    [
      _1password-cli
      acpi
      arandr
      blueberry
      cairo
      deskflow # https://github.com/deskflow/deskflow
      feh
      flameshot
      gedit
      gimp
      gtk4
      libsForQt5.qt5ct
      lxappearance
      mission-center # https://gitlab.com/mission-center-devs/mission-center
      nextcloud-client
      nixgl-pkgs.auto.nixGLDefault
      pavucontrol
      powertop
      rpi-imager # 需要暫時將用戶加入'disk'群組: `sudo usermod -aG disk $USER`
      variety
      vlc
      webcamoid

      # 普通的: bash -c '. $HOME/.nix-profile/etc/profile.d/nix.sh &&  $HOME/.nix-profile/bin/nixGL $HOME/.nix-profile/bin/rofi -show combi -font "hack 20" -combi-modi drun,window,ssh'
      # 具有 root 權限: bash -c '. $HOME/.nix-profile/etc/profile.d/nix.sh &&  $HOME/.nix-profile/bin/nixGL $HOME/.nix-profile/bin/rofi -show combi -font "hack 20" -combi-modi drun,window,ssh run-command "lxqt-sudo {cmd}" -theme-str "window { background-color:#fcc;}"'
      rofi

      paprefs

      tigervnc

      # Libre Office

      unstable-pkgs.libreoffice-qt # 需要`unstable-pkgs`先可以用密碼保護嘅檔案
      hunspell

      dillo

      # i3

      i3
      i3blocks
      i3status
      pasystray
      xdotool

      # hyprland

      adw-gtk3
      brightnessctl
      dunst
      hypridle # https://wiki.hypr.land/Hypr-Ecosystem/hypridle/
      hyprlandPlugins.hyprexpo
      hyprpaper
      libnotify # For `notify-send`
      lxqt.lxqt-sudo
      networkmanagerapplet
      playerctl
      waybar
      wdisplays
      wev
      wl-clipboard
    ]
    ++ (
      if skip-hyprland
      then []
      else [hyprland]
    )
    ++ ((has-gui-opt "copyq") copyq)
    ++ ((has-gui-opt "terminator") terminator)
    ++ ((has-gui-opt "zoom") zoom-us)
    ++ ((has-gui-opt "telegram") telegram-desktop)
    ++ ((has-gui-opt "firefox") firefox)
    ++ (lib.optional (system == "x86_64-linux") ghostty.packages.x86_64-linux.default)
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
            librime
            rime-data
            (ibus-with-plugins.override
              {plugins = [ibus-engines.rime];})
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
