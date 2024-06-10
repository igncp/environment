{
  lib,
  pkgs,
  base_config,
}: let
  is_arm_darwin = pkgs.system == "aarch64-darwin";
  go_file = base_config + "/go";
  has_go = builtins.pathExists go_file;
  go_file_content = builtins.readFile go_file;
  go_pkg =
    {
      "" = pkgs.go_1_21;
      "\n" = pkgs.go_1_21;
      "19\n" = pkgs.go_1_19;
      "20\n" = pkgs.go_1_20;
      "21\n" = pkgs.go_1_21;
    }
    ."${go_file_content}";
  extra_deps = (
    if is_arm_darwin
    then []
    else [pkgs.go-migrate pkgs.sqlc]
  );
in {
  pkgs-shell = (
    [pkgs.go_1_21]
    ++ extra_deps
  );
  pkgs-list = (
    if has_go
    then
      [go_pkg]
      ++ extra_deps
    else []
  );
}
