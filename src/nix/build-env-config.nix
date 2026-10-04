{
  base-config,
  pkgs ? null,
  root-config ? null,
}: let
  hostname-file = "/etc/hostname";
  nixos-user-file = "/etc/nixos/user";
  default-root-config = "/etc/nixos/configuration.nix";
  config-files =
    if base-config != "" && builtins.pathExists base-config
    then builtins.attrNames (builtins.readDir base-config)
    else [];
  config = builtins.listToAttrs (map (name: {
      inherit name;
      value = true;
    })
    config-files);
  is-enabled = name: builtins.hasAttr name config;
  read-config = name:
    if is-enabled name
    then builtins.readFile (base-config + "/${name}")
    else "";
  boolean-configs = {
    has-android = "android";
    has-aws = "cli-aws";
    has-azure = "azure";
    has-blocky = "blocky";
    has-c = "c";
    has-cinnamon = "gui-cinnamon";
    has_cli_hasura = "cli-hasura";
    has_cli_openvpn = "cli-openvpn";
    has-dart = "dart";
    has-docker = "docker";
    has-extra-local-rust = "extra-local-rust";
    has-expressvpn = "expressvpn";
    has-go = "go";
    has-gui = "gui";
    has-hashi = "hashi";
    has-hyprland = "gui-hyprland";
    has-iredis = "iredis";
    has-java = "java";
    has-k3s-server = "k3s-server";
    has-k3s-worker = "k3s-worker";
    has-kodi = "kodi";
    has-kotlin = "kotlin";
    has-logdy = "logdy";
    has-lua = "lua";
    has-lxqt = "gui-lxqt";
    has-minecraft = "gui-minecraft";
    has-mssql = "mssql";
    has-n8n = "n8n";
    has-pg = "postgres";
    has-php = "php";
    has-podman = "podman";
    has-printing = "printing";
    has-qemu = "qemu";
    has-rbenv = "rbenv";
    has-ruby = "ruby";
    has-shellcheck = "shellcheck";
    has-stripe = "stripe";
    has-tailscale = "tailscale";
    has-usb-luks = "usb-luks";
    has-usb-pam = "usb-pam";
    has-vscode = "gui-vscode";
    has_virtmanager = "gui-virtmanager";
    has_virtualbox = "gui-virtualbox";
    is-asus = "machine-asus";
    is-rp5 = "machine-rp5";
    is-surface = "machine-surface";
    no-1password = "gui-no-1password";
    no-bun = "no-bun";
    no-smartd = "no-smartd";
    no_watchman = "no-watchman";
  };
  text-configs = {
    go = "go";
    java = "java";
    nvidia = "nvidia";
    ruby = "ruby";
    usb-luks = "usb-luks";
    usb-pam = "usb-pam";
  };
  final-root-config =
    if root-config != null
    then root-config
    else if builtins.pathExists default-root-config
    then default-root-config
    else null;
  hostname =
    if pkgs != null && final-root-config != null
    then
      (import final-root-config {
        config = {};
        inherit pkgs;
      }).networking.hostName
    else "";
  all-configs =
    (builtins.mapAttrs (_: _: false) boolean-configs)
    // (builtins.mapAttrs (_: _: "") text-configs)
    // {
      current-hostname = "";
      hostname = "";
      nixos-user = "igncp";
      root-config = null;
      gui = [];
      usb-luks-values = [];
    };
in
  all-configs
  // (builtins.mapAttrs (_: is-enabled) boolean-configs)
  // (builtins.mapAttrs (_: read-config) text-configs)
  // {
    inherit all-configs hostname;
    current-hostname =
      if builtins.pathExists hostname-file
      then builtins.replaceStrings ["\n"] [""] (builtins.readFile hostname-file)
      else "";
    nixos-user =
      if builtins.pathExists nixos-user-file
      then builtins.replaceStrings ["\n"] [""] (builtins.readFile nixos-user-file)
      else "igncp";
    root-config = final-root-config;
    gui =
      if is-enabled boolean-configs.has-gui
      then builtins.filter (feature: feature != "") (builtins.splitString "\n" (read-config "gui"))
      else [];
    usb-luks-values =
      if is-enabled boolean-configs.has-usb-luks
      then builtins.splitString "\n" (read-config text-configs.usb-luks)
      else [];
  }
