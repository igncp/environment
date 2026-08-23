{
  lib,
  base-config,
  ...
}: let
  usb-luks-config = base-config + "/usb-luks";
  has-usb-luks = builtins.pathExists usb-luks-config;
  usb-luks-values =
    if has-usb-luks
    then lib.splitString "\n" (builtins.readFile usb-luks-config)
    else [];
  luks-usb-uuid =
    if has-usb-luks
    then builtins.elemAt usb-luks-values 0
    else "";
  luks-device-uuid =
    if has-usb-luks
    then builtins.elemAt usb-luks-values 1
    else "";
in {
  config =
    if has-usb-luks
    then
      builtins.trace "套用 USB LUKS 解密設定" {
        assertions = [
          {
            assertion = luks-usb-uuid != "";
            message = "USB LUKS 設定入面嘅 USB UUID 唔可以係空白。";
          }
          {
            assertion = luks-device-uuid != "";
            message = "USB LUKS 設定入面嘅 LUKS UUID 唔可以係空白。";
          }
        ];

        # 建立 USB key 嘅步驟：
        # > sudo mkfs.vfat -F 32 -n USBKEY /dev/sdX1
        # > sudo mkdir -p /mnt/usbkey && sudo mount /dev/sdX1 /mnt/usbkey
        # > sudo dd if=/dev/urandom of=/mnt/usbkey/bootkey.bin bs=512 count=8
        # > sudo chmod 400 /mnt/usbkey/bootkey.bin
        # > sudo umount /mnt/usbkey
        # > sudo cryptsetup luksAddKey /dev/sdY2 /mnt/usbkey/bootkey.bin
        boot.initrd = {
          availableKernelModules = [
            "usb_storage"
            "uas"
            "usbcore"
            "vfat"
            "nls_cp437"
            "nls_iso8859_1"
          ];
          systemd.enable = true;
          systemd.mounts = [
            {
              # 只讀掛載 USB，避免修改入面嘅 key file。
              what = "/dev/disk/by-uuid/${luks-usb-uuid}";
              where = "/mnt/key";
              type = "vfat";
              options = "ro";
            }
          ];
          luks.devices."${luks-device-uuid}" = {
            keyFile = "/mnt/key/bootkey.bin";
            # USB 唔存在時，10 秒後會退回手動輸入密碼。
            keyFileTimeout = 10;
            keyFileSize = 4096;
          };
        };
      }
    else {};
}
