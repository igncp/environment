{pkgs, ...}: {
  # https://zhuanlan.zhihu.com/p/463403799
  environment.systemPackages = with pkgs; [
    rime-data
  ];

  # 用緊 fcitx5係因為 ibus 同 Hyprland 唔夾
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    ibus.engines = with pkgs.fcitx5-engines; [
      rime
    ];
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-rime
      rime-data
    ];
  };
}
