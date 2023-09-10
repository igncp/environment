{
  pkgs,
  unstable,
  lib,
  bun,
  ...
}: let
  base_config = ../../project/.config;
  unstable_pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  cli-pkgs = import ../home-manager/cli.nix {inherit base_config unstable_pkgs pkgs lib;};
  node-pkgs = import ../home-manager/node.nix {inherit base_config pkgs lib unstable_pkgs bun;};
  go-pkgs = import ../home-manager/go.nix {inherit base_config pkgs lib unstable;};

  emojify = import ./emojify.nix {inherit pkgs;};

  has_c = builtins.pathExists (base_config + "/c");
  has_cli_aws = builtins.pathExists (base_config + "/cli-aws");
  has_cli_gh = builtins.pathExists (base_config + "/cli-gh");
  has_cli_openvpn = builtins.pathExists (base_config + "/cli-openvpn");
  has_ruby = builtins.pathExists (base_config + "/ruby");
  has_shellcheck = builtins.pathExists (base_config + "/shellcheck");
  has_tailscale = builtins.pathExists (base_config + "/tailscale");
  has_hashi = builtins.pathExists (base_config + "/hashi");
in {
  environment.systemPackages = with pkgs;
    [
      ack
      alsa-utils
      cacert
      cachix
      dbus
      dnsutils
      docker
      emojify
      file
      gcc
      git
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
      vim
      vnstat
    ]
    ++ cli-pkgs.pkgs-list
    ++ node-pkgs.pkgs-list
    ++ go-pkgs.pkgs-list
    ++ (lib.optional has_cli_aws pkgs.awscli2)
    ++ (lib.optional has_cli_gh pkgs.gh)
    ++ (lib.optional has_cli_openvpn pkgs.openvpn)
    ++ (lib.optional has_ruby pkgs.ruby)
    ++ (lib.optional has_c pkgs.clib)
    ++ (lib.optional has_c pkgs.ctags)
    ++ (lib.optional has_c pkgs.gcovr)
    ++ (lib.optional has_hashi pkgs.terraform-ls)
    ++ (lib.optional has_hashi pkgs.terraform)
    ++ (lib.optional has_hashi pkgs.vagrant)
    ++ (lib.optional has_shellcheck pkgs.shellcheck)
    ++ (lib.optional has_tailscale pkgs.tailscale);
}
