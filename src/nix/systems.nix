{
  nixos-generators,
  system,
  nixpkgs,
  pkgs,
  ...
}: let
  user = "igncp";
in {
  qcow-test = nixos-generators.nixosGenerate {
    system = system;
    format = "qcow";
    modules = [
      {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';

        virtualisation.diskSize = 20 * 1024;
        virtualisation.docker.enable = true;

        environment.systemPackages = with pkgs; [
          bun
          docker
          git
          nodejs_22
          rustup
        ];

        system.stateVersion = "25.05";
        programs.zsh.enable = true;
        users.users."${user}" = {
          extraGroups = ["wheel" "docker" "audio" "video" "networkmanager"];
          home = "/home/${user}";
          initialPassword = user;
          isNormalUser = true;
          shell = pkgs.zsh;
        };
      }
    ];
  };
}
