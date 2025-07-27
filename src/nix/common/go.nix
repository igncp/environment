{
  pkgs,
  base-config,
}: let
  is_arm_darwin = pkgs.system == "aarch64-darwin";
  go_file = base-config + "/go";
  has_go = builtins.pathExists go_file;
  go_file_content = builtins.readFile go_file;
  go_pkg =
    {
      "" = pkgs.go_1_23;
      "\n" = pkgs.go_1_23;
      "22\n" = pkgs.go_1_22;
      "23\n" = pkgs.go_1_23;
    }
    ."${go_file_content}";
  extra_deps = (
    if is_arm_darwin
    then []
    else [pkgs.go-migrate pkgs.sqlc]
  );
in {
  pkgs-shell = (
    [pkgs.go_1_23]
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
