{
  pkgs,
  lib,
  unstable-pkgs,
  ...
}: let
  base_config = ../../../project/.config;

  cli-pkgs = import ../common/cli.nix {
    inherit base_config;
    lib = unstable-pkgs.lib;
    pkgs = unstable-pkgs;
  };

  java-pkgs = import ../common/java.nix {
    inherit base_config;
    lib = unstable-pkgs.lib;
    pkgs = unstable-pkgs;
  };
  ruby-pkgs = import ../common/ruby.nix {
    inherit base_config;
    pkgs = unstable-pkgs;
  };
  go-pkgs = import ../common/go.nix {
    inherit base_config;
    pkgs = unstable-pkgs;
  };
  dart-pkgs = import ../common/dart.nix {
    inherit base_config;
    pkgs = unstable-pkgs;
  };

  emojify = import ./emojify.nix {inherit pkgs;};

  has_c = builtins.pathExists (base_config + "/c");
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
    ++ (lib.optional has_c pkgs.clib)
    ++ (lib.optional has_c pkgs.ctags)
    ++ (lib.optional has_c pkgs.gcovr);
}
