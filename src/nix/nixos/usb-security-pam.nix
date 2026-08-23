{
  pkgs,
  lib,
  base-config,
  ...
}: let
  usb-pam-config = base-config + "/usb-pam";
  has-usb-pam = builtins.pathExists usb-pam-config;
  usb-pam-values =
    if has-usb-pam
    then lib.splitString "\n" (builtins.readFile usb-pam-config)
    else [];
  usb-uuid =
    if has-usb-pam
    then builtins.elemAt usb-pam-values 0
    else "";
  expected-hash =
    if has-usb-pam
    then builtins.elemAt usb-pam-values 1
    else "";
  usbKeyAuthScript = pkgs.writeShellScript "usb-keyfile-check" ''
    EXPECTED_HASH="${expected-hash}"
    USB_UUID="${usb-uuid}"

    MNT_DIR=$(${pkgs.coreutils}/bin/mktemp -d)
    if ${pkgs.util-linux}/bin/mount "/dev/disk/by-uuid/$USB_UUID" "$MNT_DIR" > /dev/null 2>&1; then
      KEY_FILE="$MNT_DIR/.nixos-auth/keyfile"
      if [ -f "$KEY_FILE" ]; then
        LIVE_HASH=$(${pkgs.coreutils}/bin/sha256sum "$KEY_FILE" | ${pkgs.gawk}/bin/awk '{print $1}')
        ${pkgs.util-linux}/bin/umount "$MNT_DIR"
        ${pkgs.coreutils}/bin/rmdir "$MNT_DIR"
        if [ "$LIVE_HASH" = "$EXPECTED_HASH" ]; then
          exit 0
        fi
      else
        ${pkgs.util-linux}/bin/umount "$MNT_DIR"
        ${pkgs.coreutils}/bin/rmdir "$MNT_DIR"
      fi
    else
      ${pkgs.coreutils}/bin/rmdir "$MNT_DIR"
    fi
    exit 1
  '';
in {
  config =
    if has-usb-pam
    then
      builtins.trace "套用 USB PAM 規則" {
        assertions = [
          {
            assertion = usb-uuid != "";
            message = "USB PAM 設定入面嘅 USB UUID 唔可以係空白。";
          }
          {
            assertion = expected-hash != "";
            message = "USB PAM 設定入面嘅 SHA hash 唔可以係空白。";
          }
        ];

        environment.systemPackages = [
          pkgs.util-linux
          pkgs.coreutils
          pkgs.gawk
        ];

        security.pam.services.sudo.rules.auth.scriptBypass = {
          enable = true;
          control = "requisite";
          modulePath = "pam_exec.so";
          args = ["seteuid" "quiet" "${usbKeyAuthScript}"];
          order = 100;
        };
      }
    else {};
}
