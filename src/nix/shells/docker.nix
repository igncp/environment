{
  env-config,
  pkgs,
  lib,
  llm-agents,
}: let
  base_config = /environment/project/.config; # This requires the --impure flag
  cli-pkgs = import ../common/cli.nix {inherit env-config lib llm-agents pkgs;};
  ruby-pkgs = import ../common/ruby.nix {inherit base_config env-config pkgs;};
  go-pkgs = import ../common/go.nix {inherit base_config env-config pkgs;};
in {
  dockerEnv = pkgs.mkShell {
    TZDIR = "${pkgs.tzdata}/share/zoneinfo";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    packages =
      cli-pkgs.pkgs-list
      ++ ruby-pkgs.pkgs-list
      ++ go-pkgs.pkgs-list
      ++ (with pkgs; [
        bun
        cacert
        glibcLocales
        libyaml
        ncurses5 # 對於 `tput`
        nodejs_22
        openssh # 對於 `sshd`
        openssl
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
