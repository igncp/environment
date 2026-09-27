{
  pkgs,
  env-config,
}: let
  is_arm_darwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
  go_pkg =
    {
      "" = pkgs.go;
      "\n" = pkgs.go;
      "22\n" = pkgs.go_1_22;
      "23\n" = pkgs.go_1_23;
    }
    ."${env-config.go}";
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
    if env-config.has-go
    then
      [go_pkg]
      ++ extra_deps
    else []
  );
}
