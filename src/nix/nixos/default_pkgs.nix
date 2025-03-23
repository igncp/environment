{
  pkgs,
  lib,
  unstable-pkgs,
  ...
}: let
  base_config = ../../../project/.config;

  cli-pkgs = import ../common/cli.nix {
    inherit base_config lib;
    pkgs = unstable-pkgs;
  };

  java-pkgs = import ../common/java.nix {inherit base_config lib pkgs;};
  ruby-pkgs = import ../common/ruby.nix {inherit base_config pkgs;};
  go-pkgs = import ../common/go.nix {inherit base_config pkgs;};
  dart-pkgs = import ../common/dart.nix {inherit base_config pkgs;};

  emojify = import ./emojify.nix {inherit pkgs;};

  has_c = builtins.pathExists (base_config + "/c");
  has_go = builtins.pathExists (base_config + "/go");
in {
  environment.systemPackages = with pkgs;
    [
      alsa-utils
      cacert
      dbus
      dnsutils
      docker
      emojify
      file
      gcc
      gnupg
      htop
      lshw
      openssl
      openssl.dev
      openvpn
      pciutils # 包括 lspci
      ps_mem
      python3
      tree-sitter
      vnstat

      # Coding

      bun
      nodejs_22
      rustup
    ]
    ++ cli-pkgs.pkgs-list
    ++ java-pkgs.pkgs-list
    ++ ruby-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ dart-pkgs.pkgs-list
    ++ (lib.optional has_go unstable-pkgs.go)
    ++ (lib.optional has_c pkgs.clib)
    ++ (lib.optional has_c pkgs.ctags)
    ++ (lib.optional has_c pkgs.gcovr);
}
