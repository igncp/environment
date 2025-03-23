{
  pkgs,
  base_config,
}: let
  has_lua = builtins.pathExists (base_config + "/lua");
in rec {
  lua_pkgs = with pkgs; [
    lua

    # 對於本地安裝，請使用 `--tree`: https://leafo.net/guides/customizing-the-luarocks-tree.html
    # 需要設定載入路徑
    luarocks
  ];

  pkgs-list =
    if has_lua
    then lua_pkgs
    else [];
}
