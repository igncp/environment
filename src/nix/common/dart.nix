{
  pkgs,
  env-config,
}: let
  is_arm_darwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
  extra_deps = (
    if is_arm_darwin
    then []
    else [
      pkgs.go-migrate
      pkgs.sqlc
    ]
  );
in {
  pkgs-shell = [pkgs.go_1_23] ++ extra_deps;
  pkgs-list = (
    if env-config.has-dart
    then
      [
        pkgs.dart
        pkgs.flutter
      ]
      ++ extra_deps
    else []
  );
}
