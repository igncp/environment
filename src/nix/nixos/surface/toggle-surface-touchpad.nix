{
  pkgs,
  env-config,
  ...
}: let
  touchpadHelper = pkgs.writeShellScriptBin "touchpad-toggle-helper" ''
    #!/usr/bin/env bash
    set -e

    STATUS="''${1:-1}"
    DEVICE_PATH="$(${pkgs.coreutils}/bin/cat /proc/bus/input/devices |
      ${pkgs.gnugrep}/bin/grep 'Microsoft Surface Keyboard Touchpad' -A2 |
      ${pkgs.gnugrep}/bin/grep Sysfs |
      ${pkgs.gnugrep}/bin/grep -o '/devices.*')"

    ${pkgs.util-linux}/bin/logger -t set_touchpad "設定觸控板 DEVICE_PATH：$DEVICE_PATH $STATUS"

    echo "$STATUS" > "/sys$DEVICE_PATH/inhibited"
  '';

  enableTouchpad = pkgs.writeShellScriptBin "touchpad-enable" ''
    #!/usr/bin/env bash
    sudo ${touchpadHelper}/bin/touchpad-toggle-helper 0
  '';

  disableTouchpad = pkgs.writeShellScriptBin "touchpad-disable" ''
    #!/usr/bin/env bash
    sudo ${touchpadHelper}/bin/touchpad-toggle-helper 1
  '';

  enableShortcut = pkgs.makeDesktopItem {
    name = "touchpad-enable-shortcut";
    desktopName = "啟用觸控板";
    comment = "啟用 Microsoft Surface 觸控板";
    exec = "${enableTouchpad}/bin/touchpad-enable";
    icon = "input-touchpad";
    terminal = false;
    categories = ["Settings" "HardwareSettings"];
  };

  disableShortcut = pkgs.makeDesktopItem {
    name = "touchpad-disable-shortcut";
    desktopName = "停用觸控板";
    comment = "抑制／停用 Microsoft Surface 觸控板";
    exec = "${disableTouchpad}/bin/touchpad-disable";
    icon = "input-touchpad";
    terminal = false;
    categories = ["Settings" "HardwareSettings"];
  };
in {
  environment.systemPackages = [
    enableShortcut
    disableShortcut
  ];

  security.sudo.extraRules = [
    {
      users = [env-config.nixos-user];
      commands = [
        {
          command = "${touchpadHelper}/bin/touchpad-toggle-helper";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
