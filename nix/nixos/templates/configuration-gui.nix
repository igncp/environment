# 編輯此設定檔以定義系統上應安裝的內容。
# 幫助可以在configuration.nix(5)手冊頁和NixOS手冊中找到
# （透過執行‘nixos-help’來存取）
{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  networking.extraHosts = ''
    192.168.1.50 foo
  '';

  # environment.etc."resolv.conf".text = "nameserver 192.168.1.1\n";
}
