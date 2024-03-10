# 環境

這個程式碼庫包含我的個人環境配置和一些開發筆記。

它由透過安裝程式、生成設定檔等來配置環境的腳本組成。運行該配置必須盡可能是冪等的，因此多次運行它應該會使系統處於與第一次相同的狀態。

這些部分是：

- Bash 配置腳本位於 [src](./src)
- Nix 配置在 [nix](./nix):
    - 對於 NixOS 和[Home Manager](https://github.com/nix-community/home-manager) (用於其他 Unix 作業系統)
    - 對於這兩種情況，主要入口點是 [flake.nix](./flake.nix) 文件
    - 包含多個 nix shell
- Dot和設定檔位於 [src/config-files](./src/config-files)
- 一些 Rust 和 bash CLI 應用程式 [src/scripts](src/scripts)
- 多個專案的範本檔案 (ts, docker, 等等): [src/project_templates](./src/project_templates)
- 另外還有一些 [個人筆記](./notes)

## 許可證

MIT
