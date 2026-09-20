{
  pkgs,
  lib,
  unstable-pkgs,
  llm-agents,
  env-config,
  ...
}: let
  base-config = ../../../project/.config;
  cli-pkgs = import ../common/cli.nix {
    inherit env-config llm-agents;
    lib = unstable-pkgs.lib;
    pkgs = unstable-pkgs;
  };

  java-pkgs = import ../common/java.nix {
    inherit base-config env-config;
    lib = unstable-pkgs.lib;
    pkgs = unstable-pkgs;
  };
  ruby-pkgs = import ../common/ruby.nix {
    inherit base-config env-config;
    pkgs = unstable-pkgs;
  };
  go-pkgs = import ../common/go.nix {
    inherit base-config env-config;
    pkgs = unstable-pkgs;
  };
  dart-pkgs = import ../common/dart.nix {
    inherit env-config;
    pkgs = unstable-pkgs;
  };
in {
  environment.systemPackages =
    []
    ++ cli-pkgs.pkgs-list
    ++ java-pkgs.pkgs-list
    ++ ruby-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ dart-pkgs.pkgs-list
    ++ (lib.optional env-config.has-docker pkgs.docker)
    ++ (lib.optional env-config.has-c pkgs.clib)
    ++ (lib.optional env-config.has-c pkgs.ctags)
    ++ (lib.optional env-config.has-c pkgs.gcovr);
}
