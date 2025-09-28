{
  pkgs,
  lib,
  unstable-pkgs,
  ...
}: let
  base-config = ../../../project/.config;

  cli-pkgs = import ../common/cli.nix {
    inherit base-config;
    lib = unstable-pkgs.lib;
    pkgs = unstable-pkgs;
  };

  java-pkgs = import ../common/java.nix {
    inherit base-config;
    lib = unstable-pkgs.lib;
    pkgs = unstable-pkgs;
  };
  ruby-pkgs = import ../common/ruby.nix {
    inherit base-config;
    pkgs = unstable-pkgs;
  };
  go-pkgs = import ../common/go.nix {
    inherit base-config;
    pkgs = unstable-pkgs;
  };
  dart-pkgs = import ../common/dart.nix {
    inherit base-config;
    pkgs = unstable-pkgs;
  };

  has-c = builtins.pathExists (base-config + "/c");
  has-docker = builtins.pathExists (base-config + "/docker");
in {
  environment.systemPackages =
    []
    ++ cli-pkgs.pkgs-list
    ++ java-pkgs.pkgs-list
    ++ ruby-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ dart-pkgs.pkgs-list
    ++ (lib.optional has-docker pkgs.docker)
    ++ (lib.optional has-c pkgs.clib)
    ++ (lib.optional has-c pkgs.ctags)
    ++ (lib.optional has-c pkgs.gcovr);
}
