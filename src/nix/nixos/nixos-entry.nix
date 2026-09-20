{
  ghostty,
  home-manager,
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
}: let
  base-config = ../../../project/.config;
  has-user-file = builtins.pathExists "/etc/nixos/user"; # 用呢個指令：`sudo bash -c 'printf USER_NAME > /etc/nixos/user'`
  is-rp5-install = builtins.getEnv "IS_RP5_INSTALL" == "1";
  is-rp5 = let
    detected =
      env-config.is-rp5
      || is-rp5-install;
  in
    if detected
    then builtins.trace "偵測到 RP5 設定" detected
    else false;
  hostname =
    (import /etc/nixos/configuration.nix {
      inherit pkgs config;
    })
    .networking
    .hostName;
  configuration-name =
    if is-rp5-install
    then "rp5"
    else hostname;
  config = {};
  lib = nixpkgs.lib;
  current-hostname = builtins.readFile "/etc/hostname";
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
      home-manager
      system
      ghostty
      nixos-hardware
      base-config
      unstable
      nixgl-pkgs
      llm-agents
      env-config
      is-rp5
      is-rp5-install
      ;
    nixos-raspberrypi = nixos-raspberry;
    unstable-pkgs = pkgs;

    # 硬編碼這個值，因為它等於 nixos 中的 “root”
    user =
      if has-user-file
      then (builtins.readFile "/etc/nixos/user")
      else "igncp";
  };
  rp5-config = import ./rp5.nix {
    inherit
      base-config
      disko
      env-config
      lib
      llm-agents
      modules-list
      nixos-raspberry
      pkgs
      is-rp5-install
      specialArgs
      ;
  };
  installer-config = import ./installer.nix {
    inherit base-config disko env-config lib llm-agents nixpkgs pkgs system;
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
  final-config
  // (
    # 這樣做是為了能夠更改“主機名稱”。更改後需重新啟動。
    if current-hostname != configuration-name
    then {"${current-hostname}" = final-config."${configuration-name}";}
    else {}
  )
