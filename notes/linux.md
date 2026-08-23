# Linux 可開機 USB

- 喺 macOS 上使用：Balena Etcher - https://etcher.balena.io/#download-etcher
- 另一個方法：
  - `diskutil list`
  - `diskutil unmountDisk /dev/diskN`
  - 用 `dd` 將 ISO 寫入磁碟（使用 `rdisk` 會比 `disk` 更快）
  - `sudo dd if=/Users/igncp/Downloads/nixos-minimal-26.05.8111.5880666fd9eb-x86_64-linux.iso of=/dev/rdisk6 status=progress`

# 網絡

## 排除緊現有嘅配置故障

- `cat /etc/network/interfaces`
- 檢查 networkd 有冇運行：`systemctl list-units | grep networkd`
- 檢查有冇使用 `netctl`：`netctl list`
- 檢查有冇使用 NetworkManager：`nmcli`
    - 你可以用 TUI: `nmtui`

## 靜態 IP （冇 dhcpcd ）

- Arch Linux - Via netctl
    - 複製 `/etc/netctl/examples` 入面嘅範例，再設定靜態 IP
    - 加入以下內容：
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
    - 將 addresses 入面嘅 `X` 改成想要嘅數字
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

# Arch Linux 使用提示

## 作為主機

- 推薦做法：https://wiki.archlinux.org/index.php/general_recommendations
- 電源管理：https://wiki.archlinux.org/index.php/Power_management
- 螢幕亮度：https://wiki.archlinux.org/index.php/Backlight#ACPI
- 鎖定螢幕：https://hund0b1.gitlab.io/2019/01/08/using-i3lock-with-systemd-suspend.html
- 字型：https://wiki.archlinux.org/index.php/Font_configuration

# 設定新系統

- 同步正常應用程式
- 讓視訊、音訊和麥克風與 Google Meet 搭配使用

# Linux 筆電指南

- NixOS
- X11 - 能夠使用 Deskflow
- I3

- 推薦配置：https://nixos.wiki/wiki/Laptop

## 系統管理

- Mission Center：系統概覽
