{
  pkgs,
  base_config,
}: let
  has_ruby = builtins.pathExists (base_config + "/ruby");
in {
  pkgs-list = (
    if has_ruby
    then [pkgs.ruby]
    else []
  );
}
