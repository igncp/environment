# Linux bootable USB

- From mac: Balena Etcher - https://etcher.balena.io/#download-etcher

# 網絡

## 排除緊現有嘅配置故障

- `cat /etc/network/interfaces`
- Check if networkd is running: `systemctl list-units | grep networkd`
- Check if using `netctl`: `netctl list`
- Check if using network manager: `nmcli`
    - 你可以用 TUI: `nmtui`

## 靜態 IP （冇 dhcpcd ）

- Arch Linux - Via netctl
    - Copying the one in `/etc/netctl/examples` with static IP
    - It involves adding the following:
```
IP=static
Address='192.168.1.55/24'
Gateway='192.168.1.1'
DNS=('192.168.1.1')
```
- Ubuntu Server 20.x: `sudo vim /etc/netplan/00-installer-config.yaml`
```
network:
  ethernets:
    enp0s3:
      addresses: [192.168.1.X/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [4.2.2.2, 8.8.8.8]
  version: 2
```
    - Update the `X` in addresses with the desired number
    - `sudo netplan apply`
    - `reboot`

## `nmcli`

```sh
sudo nmcli con delete SSID # 萬一之前存在過
sudo nmcli device wifi connect SSID password PASSWORD
sudo nmcli dev wifi # 列出所有SSID
```

# 雙啟動

- Windows + Linux: 首先安裝 Windows

# NixOS 提示

- 安裝: [src/os/nixos/install.sh](../src/os/nixos/install.sh)

## `nix repl`

- `:lf .`: 喺當前目錄入面載入flake
- `inputs.unstable.legacyPackages.x86_64-linux.linuxPackages<Tab>`: 列出可用嘅內核

# Arch Linux Tips

## As Host

- Recommendations: https://wiki.archlinux.org/index.php/general_recommendations
- Power Management: https://wiki.archlinux.org/index.php/Power_management
- Brightness: https://wiki.archlinux.org/index.php/Backlight#ACPI
- Lock Screen: https://hund0b1.gitlab.io/2019/01/08/using-i3lock-with-systemd-suspend.html
- Fonts: https://wiki.archlinux.org/index.php/Font_configuration

# 設定新系統

- 同步正常應用程式
- 讓視訊、音訊和麥克風與 Google Meet 搭配使用
