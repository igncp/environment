{
  ghostty,
  home-manager,
  colmena,
  nixgl-pkgs,
  nixos-hardware,
  nixpkgs,
  pkgs,
  stable-pkgs,
  system,
  unstable,
  nixos-raspberry,
  llm-agents,
  disko,
  env-config,
  as-module ? false,
}: let
  is-rp5-install = builtins.getEnv "IS_RP5_INSTALL" == "1";
  is-rp5 = let
    detected =
      env-config.is-rp5
      || is-rp5-install;
  in
    if detected
    then builtins.trace "偵測到 RP5 設定" detected
    else false;
  configuration-name =
    if is-rp5-install
    then "rp5"
    else env-config.hostname;
  lib = nixpkgs.lib;
  modules-list =
    [
      ./configuration.nix
    ]
    ++ (
      if env-config.is-surface
      then [./nixos-surface.nix]
      else []
    )
    ++ (
      if env-config.is-asus
      then [./nixos-asus.nix]
      else []
    );
  specialArgs = {
    inherit
      stable-pkgs
      colmena
      home-manager
      system
      ghostty
      nixos-hardware
      unstable
      nixgl-pkgs
      llm-agents
      env-config
      is-rp5
      is-rp5-install
      ;
    nixos-raspberrypi = nixos-raspberry;
    unstable-pkgs = pkgs;
    user = env-config.nixos-user;
  };
  rp5-config = import ./rp5.nix {
    inherit
      disko
      env-config
      lib
      llm-agents
      modules-list
      nixos-raspberry
      pkgs
      stable-pkgs
      is-rp5-install
      specialArgs
      ;
  };
  installer-config = import ./installer.nix {
    inherit colmena disko env-config lib llm-agents nixpkgs pkgs system;
  };
  module-config = {
    imports =
      modules-list
      ++ lib.optionals is-rp5 [
        nixos-raspberry.lib.int.full-nixos-raspberrypi-config
        nixos-raspberry.nixosModules.raspberry-pi-5.base
      ];
  };
  final-config =
    {
      "${configuration-name}" =
        if is-rp5 != true
        then
          (
            nixpkgs.lib.nixosSystem {
              modules = modules-list;
              specialArgs = specialArgs;
            }
          )
        else rp5-config;
    }
    // installer-config;
in
  if as-module
  then {
    module = module-config;
    inherit specialArgs;
  }
  else
    final-config
    // (
      # 這樣做是為了能夠更改“主機名稱”。更改後需重新啟動。
      if
        env-config.current-hostname
        != ""
        && env-config.current-hostname != configuration-name
      then {"${env-config.current-hostname}" = final-config."${configuration-name}";}
      else {}
    )
