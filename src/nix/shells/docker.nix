{
  pkgs,
  lib,
}: let
  base_config = /environment/project/.config; # This requires the --impure flag
  cli-pkgs = import ../common/cli.nix {inherit pkgs base_config lib;};
  ruby-pkgs = import ../common/ruby.nix {inherit base_config pkgs;};
  go-pkgs = import ../common/go.nix {inherit base_config pkgs;};
in {
  dockerEnv = pkgs.mkShell {
    TZDIR = "${pkgs.tzdata}/share/zoneinfo";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";

    packages =
      cli-pkgs.pkgs-list
      ++ ruby-pkgs.pkgs-list
      ++ go-pkgs.pkgs-list
      ++ (with pkgs; [
        bun
        glibcLocales
        nodejs_22
        openssh # 對於 `sshd`
        rustup
        shadow
        su
        sudo
        tzdata
        util-linux
        zsh
      ]);
  };
}
