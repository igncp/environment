{
  pkgs,
  lib,
  unstable_pkgs,
  ...
}: let
  base_config = ../../project/.config;

  cli-pkgs = import ../common/cli.nix {
    inherit base_config lib;
    pkgs = unstable_pkgs;
  };

  java-pkgs = import ../common/java.nix {inherit base_config lib pkgs;};
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
    ++ (lib.optional has_go unstable_pkgs.go)
    ++ (lib.optional has_c pkgs.clib)
    ++ (lib.optional has_c pkgs.ctags)
    ++ (lib.optional has_c pkgs.gcovr);
}
