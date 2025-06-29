{
  ghostty,
  home-manager,
  nixos-hardware,
  nixpkgs,
  pkgs,
  stable-pkgs,
  system,
  unstable,
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
in {
  "${hostname}" = nixpkgs.lib.nixosSystem {
    modules =
      [
        ./configuration.nix
      ]
      ++ (
        if is-surface
        then [./nixos-surface.nix]
        else []
      );
    specialArgs = {
      inherit stable-pkgs home-manager system ghostty nixos-hardware base-config unstable;
      unstable-pkgs = pkgs;

      # 硬編碼這個值，因為它等於 nixos 中的 “root”
      user =
        if has-user-file
        then (builtins.readFile "/etc/nixos/user")
        else "igncp";
    };
  };
}
