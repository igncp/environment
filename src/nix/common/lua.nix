{
  pkgs,
  env-config,
}: let
in rec {
  lua_pkgs = with pkgs; [
    lua

    # 對於本地安裝，請使用 `--tree`: https://leafo.net/guides/customizing-the-luarocks-tree.html
    # 需要設定載入路徑
    luarocks
  ];

  pkgs-list =
    if env-config.has-lua
    then lua_pkgs
    else [];
}
