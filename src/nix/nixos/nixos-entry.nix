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
}: let
  base-config = ../../../project/.config;
  has-user-file = builtins.pathExists "/etc/nixos/user"; # 用呢個指令：`sudo bash -c 'printf USER_NAME > /etc/nixos/user'`
  is-surface = builtins.pathExists (base-config + "/machine-surface");
  is-asus = builtins.pathExists (base-config + "/machine-asus");
  is-rp5-install = builtins.getEnv "IS_RP5_INSTALL" == "1";
  is-rp5 = let
    detected =
      builtins.pathExists (base-config + "/machine-rp5")
      || is-rp5-install;
  in
    if detected
    then builtins.trace "偵測到 RP5 設定" detected
    else false;
  configuration-name =
    if is-rp5
    then "rp5-poe"
    else hostname;
  config = {};
  lib = nixpkgs.lib;
  hostname =
    (import /etc/nixos/configuration.nix {
      inherit pkgs config;
    })
    .networking
    .hostName;
  current-hostname = builtins.readFile "/etc/hostname";
  modules-list =
    [
      ./configuration.nix
    ]
    ++ (
      if is-surface
      then [./nixos-surface.nix]
      else []
    )
    ++ (
      if is-asus
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
    inherit base-config lib llm-agents nixpkgs pkgs system disko;
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
