{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ibus
    rime-data
  ];

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      rime
    ];
  };
}
