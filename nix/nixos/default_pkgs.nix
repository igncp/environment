{
  pkgs,
  unstable,
  lib,
  ...
}: let
  base_config = ../../project/.config;
  unstable_pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  cli-pkgs = import ../common/cli.nix {inherit base_config unstable_pkgs pkgs lib;};
  node-pkgs = import ../common/node.nix {inherit base_config pkgs lib unstable_pkgs;};
  go-pkgs = import ../common/go.nix {inherit base_config pkgs lib unstable;};
  ruby-pkgs = import ../common/ruby.nix {inherit base_config pkgs;};

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
      nixopsUnstable
      openssl
      ps_mem
      rustup
      sqlite
      statix
      unstable_pkgs.nix-init # https://github.com/nix-community/nix-init
      valgrind
      vnstat
    ]
    ++ cli-pkgs.pkgs-list
    ++ node-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ ruby-pkgs.pkgs-list
    ++ (lib.optional has_c pkgs.clib)
    ++ (lib.optional has_c pkgs.ctags)
    ++ (lib.optional has_c pkgs.gcovr);
}
