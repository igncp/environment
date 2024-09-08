# nixpkgs 中有一個現有的內建 `logdy`
# 包，但出於學習目的創建了一個包，因為它對我來說不是一個關鍵工具，
# 可以中斷更新。它使用存儲庫中當前最新的commit。
# 警告：Web 文件不適用於此提交，請使用 cli 說明。
{pkgs}:
pkgs.buildGoModule {
  name = "logdy";
  src = pkgs.fetchFromGitHub {
    owner = "logdyhq";
    # @upgrade
    rev = "3a8df92074d01eecf37e62cc127df596f4242787";
    repo = "logdy-core";
    sha256 = "sha256-G01eCK1iM4B4oiUzAiDmWA8qMo+V/HDnphJtcUl8QSA";
  };

  vendorHash = "sha256-kFhcbBMymzlJ+2zw7l09LJfCdps26Id+VzOehqrLDWU=";

  postInstall = ''
    mv $out/bin/logdy-core $out/bin/logdy
    rm -f $out/bin/example-app
  '';
}
