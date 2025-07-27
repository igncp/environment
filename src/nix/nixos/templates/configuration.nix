# 編輯此設定檔以定義系統上應安裝的內容。
# 幫助可以在configuration.nix(5)手冊頁和NixOS手冊中找到
# （透過執行‘nixos-help’來存取）
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "nixos";

  networking.extraHosts = ''
    192.168.1.50 foo
  '';

  # 喺非 GUI 入面移除
  environment.systemPackages = with pkgs; [
    # 如果冇執行任何條文，就可以用 Hyprland
    kitty
  ];

  # environment.etc."resolv.conf".text = "nameserver 192.168.1.1\n";

  # nix.settings.trusted-users = ["igncp"]; # When the current machine is a remote builder

  # # 當用緊遠端建立工具嗰陣，喺本機入面
  # # https://nixos.wiki/wiki/Distributed_build
  # # 為咗確保佢係用緊遠端構建器，請使用 `-j 0` （最多本地工作）選項
  # nix.buildMachines = [
  #   {
  #     sshUser = "igncp";
  #     sshKey = "/home/foo/.ssh/nix-remote-builder"; # Change the user and key
  #     hostName = "192.168.1.X"; # Change the IP
  #     maxJobs = 2;
  #     system = "x86_64-linux";
  #     supportedFeatures = ["big-parallel"];
  #     mandatoryFeatures = ["big-parallel"];
  #   }
  # ];
  # nix.distributedBuilds = true;
}
