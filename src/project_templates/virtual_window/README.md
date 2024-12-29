## 推薦設定

- 系統：帶有預設顯示管理器的 Raspbian
- 要求：
    - 自動開始隨機視頻
    - VNC控制
    - 如果可能的話，同步視訊時間
    - 影片結束時繼續播放
    - 預設無法上網

步驟：

1. 刷新 SD 卡時，使用 Raspberry Pi Imager 設定 wifi 和基本 ssh。
1. 使用`sudo raspi-config`啟用VNC伺服器。若要進行連接，請啟用檢視器中的所有安全性選項。
1. 配置環境以便能夠使用最新版本的yt-dlp（目前的Debian版本不起作用）
1. 設定

- `root`:

```
apt update
apt install -y ufw

mkdir -p /home/igncp/.ssh
curl https://github.com/igncp.keys > /home/igncp/.ssh/authorized_keys
chown igncp:igncp /home/igncp/.ssh/authorized_keys

# SSH配置
sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config
systemctl restart sshd

# 防火牆
ufw enable
ufw allow ssh
```

- `igncp`:

```
mkdir -p ~/.config/systemd/user/
mkdir -p ~/VirtualWindow
nvim ~/.config/wf-panel-pi.ini # Add `autohide = true`
systemctl --user link $HOME/development/environment/src/project_templates/virtual_window/virtual-window.service
systemctl --user daemon-reload
systemctl --user enable --now virtual-window.service
sudo systemctl link $HOME/development/environment/src/project_templates/virtual_window/virtual-window-check.timer
sudo systemctl link $HOME/development/environment/src/project_templates/virtual_window/virtual-window-check.service
sudo systemctl enable --now virtual-window-check.timer
sudo ufw default deny outgoing
```
