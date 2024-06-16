{
  pkgs,
  lib,
  ...
}: let
  base_config = ../../project/.config;

  cli-pkgs = import ../common/cli.nix {inherit base_config pkgs lib;};
  node-pkgs = import ../common/node.nix {inherit base_config lib pkgs;};
  go-pkgs = import ../common/go.nix {inherit base_config lib pkgs;};
  ruby-pkgs = import ../common/ruby.nix {inherit base_config pkgs;};
  rust-pkgs = import ../common/rust.nix {inherit pkgs base_config;};
  java-pkgs = import ../common/java.nix {inherit base_config lib pkgs;};

  has_c = builtins.pathExists (base_config + "/c");

  emojify = import ./emojify.nix {inherit pkgs;};
in {
  environment.systemPackages = with pkgs;
    [
      alsa-utils
      cacert
      cachix
      dbus
      dnsutils
      docker
      emojify
      file
      gcc
      gnupg
      lshw
      openssl
      openssl.dev
      openvpn
      pciutils # 包括 lspci
      ps_mem
      statix
      vnstat
    ]
    ++ cli-pkgs.pkgs-list
    ++ node-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ ruby-pkgs.pkgs-list
    ++ rust-pkgs.pkgs-list-conditional
    ++ java-pkgs.pkgs-list
    ++ (lib.optional has_c pkgs.clib)
    ++ (lib.optional has_c pkgs.ctags)
    ++ (lib.optional has_c pkgs.gcovr);
}
