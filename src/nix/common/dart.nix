{
  pkgs,
  base_config,
}: let
  is_arm_darwin = pkgs.system == "aarch64-darwin";
  dart_file = base_config + "/dart";
  has_dart = builtins.pathExists dart_file;
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
    if has_dart
    then
      [
        pkgs.dart
        pkgs.flutter
      ]
      ++ extra_deps
    else []
  );
}
