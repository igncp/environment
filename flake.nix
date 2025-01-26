{
  description = "Root flake for NixOS, Nix shells and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-24.05";
    };
    ghostty = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = {
    home-manager,
    flake-utils,
    nixpkgs,
    self,
    unstable,
    ghostty,
  }: let
    user = builtins.getEnv "USER";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        stable_pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import unstable {
          system = stable_pkgs.system;
          config.allowUnfree = true;
        };
        config = {};
        hostname = (import /etc/nixos/configuration.nix {inherit pkgs config;}).networking.hostName;
        devShells = import ./nix/shells/main.nix {inherit pkgs;};
        has_user_file = builtins.pathExists "/etc/nixos/user"; # Use: `sudo bash -c 'printf USER_NAME > /etc/nixos/user'`
      in {
        inherit devShells;
        packages = {
          nixosConfigurations = {
            "${hostname}" = nixpkgs.lib.nixosSystem {
              modules = [
                ./nix/nixos/configuration.nix
              ];
              specialArgs = {
                inherit stable_pkgs home-manager system ghostty;
                unstable_pkgs = pkgs;

                # 硬編碼這個值，因為它等於 nixos 中的 “root”
                user =
                  if has_user_file
                  then (builtins.readFile "/etc/nixos/user")
                  else "igncp";
              };
            };
          };
          homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [./nix/home-manager/home.nix];
            extraSpecialArgs = {inherit pkgs stable_pkgs;};
          };
        };
      }
    );
}
