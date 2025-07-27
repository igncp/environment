{
  lib,
  pkgs,
  system,
  unstable-pkgs,
  base-config,
  ...
}: let
  gui-content = builtins.readFile (base-config + "/gui");
  has-vscode = builtins.pathExists (base-config + "/gui-vscode");

  has-gui-opt = infix: lib.optional (lib.strings.hasInfix infix gui-content);
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
      keepass
      libsForQt5.qt5ct
      nextcloud-client
      pavucontrol
      rpi-imager # 需要暫時將用戶加入'disk'群組: `sudo usermod -aG disk $USER`
      variety
      vlc
      webcamoid

      tigervnc

      # Libre Office

      unstable-pkgs.libreoffice-qt # 需要`unstable-pkgs`先可以用密碼保護嘅檔案
      hunspell

      dillo
    ]
    ++ ((has-gui-opt "copyq") copyq)
    ++ ((has-gui-opt "terminator") terminator)
    ++ ((has-gui-opt "zoom") zoom-us)
    ++ ((has-gui-opt "telegram") telegram-desktop)
    ++ ((has-gui-opt "firefox") firefox)
    ++ (lib.optional has-vscode vscode)
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
