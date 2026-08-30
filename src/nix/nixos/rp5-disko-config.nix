# Can do in a VM forwarding the USB
# It will mount in /mnt
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sdc"; # @TODO: 透過環境變數傳入
    content = {
      type = "gpt";
      partitions = {
        firmware = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptpi";
            passwordFile = "/home/igncp/development/environment/src/nix/nixos/rp5-initial-pass.txt"; # @TODO: 使用環境變數建構
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
