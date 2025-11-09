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
  vscode-server,
}: let
  base-config = ../../../project/.config;
  has-user-file = builtins.pathExists "/etc/nixos/user"; # 用呢個指令: `sudo bash -c 'printf USER_NAME > /etc/nixos/user'`
  is-surface = builtins.pathExists (base-config + "/surface");
  config = {};
  hostname =
    (import /etc/nixos/configuration.nix {
      inherit pkgs config;
    })
    .networking
    .hostName;
  current-hostname = builtins.readFile "/etc/hostname";
  final-config = {
    "${hostname}" = nixpkgs.lib.nixosSystem {
      modules =
        [
          ./configuration.nix
          vscode-server.nixosModules.default
        ]
        ++ (
          if is-surface
          then [./nixos-surface.nix]
          else []
        );
      specialArgs = {
        inherit stable-pkgs home-manager system ghostty nixos-hardware base-config unstable nixgl-pkgs;
        unstable-pkgs = pkgs;

        # 硬編碼這個值，因為它等於 nixos 中的 “root”
        user =
          if has-user-file
          then (builtins.readFile "/etc/nixos/user")
          else "igncp";
      };
    };
  };
in
  final-config
  // (
    # 這樣做是為了能夠更改“主機名稱”。更改後需重新啟動。
    if current-hostname != hostname
    then {"${current-hostname}" = final-config."${hostname}";}
    else {}
  )
