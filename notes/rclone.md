## 設定 Rclone 做檔案分享

### 由已經設定好嘅電腦搬過嚟

- 複製 `$HOME/.config/rclone` 呢個目錄
- `mkdir -p ~/common-files && rclone sync common-files-crypt: ~/common-files -P`

### 由零開始設定

- `rclone config`: 用 GCloud Console 嘅 client id 同 secret 幫你個帳戶做設定
- `rclone config`: 設定 `crypt` remote，將佢對應去 GDrive remote 入面其中一個目錄，例如 `my-gdrive-remote:common-files`
    - 幫個 remote 改個名，例如 `common-files-crypt`
- `rclone sync common-files-crypt: ~/common-files`
