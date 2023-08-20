{base_config}: {
  pkgs,
  lib,
  go-21,
  ...
}: let
  go-21-pkgs = import go-21 {
    system = pkgs.system;
  };
  go_file = base_config + "/go";
  has_go = builtins.pathExists go_file;
  go_file_content = builtins.readFile go_file;
  go_pkg =
    {
      "" = pkgs.go;
      "\n" = pkgs.go;
      "19\n" = pkgs.go_1_19;
      "20\n" = pkgs.go_1_20;
      # For 21: https://github.com/NixOS/nixpkgs/pull/246935
      "21\n" = go-21-pkgs.go_1_21;
    }
    ."${go_file_content}";
in {
  home.packages =
    []
    ++ (lib.optional has_go go_pkg);
}
