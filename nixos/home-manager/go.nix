{
  pkgs,
  lib,
  unstable,
  base_config,
}: let
  unstable-pkgs = import unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  is_arm_darwin = pkgs.system == "aarch64-darwin";
  go_file = base_config + "/go";
  has_go = builtins.pathExists go_file;
  go_file_content = builtins.readFile go_file;
  go_pkg =
    {
      "" = unstable-pkgs.go_1_21;
      "\n" = unstable-pkgs.go_1_21;
      "19\n" = pkgs.go_1_19;
      "20\n" = pkgs.go_1_20;
      "21\n" = unstable-pkgs.go_1_21;
    }
    ."${go_file_content}";
in {
  pkgs-list = (
    if has_go
    then
      (
        [go_pkg]
        ++ (
          if is_arm_darwin
          then []
          else [unstable-pkgs.go-migrate unstable-pkgs.sqlc]
        )
      )
    else []
  );
}
