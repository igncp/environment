{pkgs, ...}: {
  environment.variables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };

  # https://zhuanlan.zhihu.com/p/463403799
  environment.systemPackages = with pkgs; [
    rime-data
  ];

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      rime
    ];
  };
}
