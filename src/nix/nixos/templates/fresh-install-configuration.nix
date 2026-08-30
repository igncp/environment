# sudo nix-channel --add https://nixos.org/channels/nixos-26.05 nixos
# sudo nix-channel --update
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "nixos";

  # 喺非 GUI 入面移除
  environment.systemPackages = with pkgs; [
    # 如果冇執行任何條文，就可以用 Hyprland
    kitty

    neovim
    git
    alejandra
    tmux
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;
  users.users.igncp = {
    isNormalUser = true;
    home = "/home/igncp";
    extraGroups = [
      "wheel"
      "docker"
      "audio"
      "video"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };
}
