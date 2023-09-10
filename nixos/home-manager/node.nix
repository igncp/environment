{
  base_config,
  bun,
  lib,
  pkgs,
  unstable_pkgs,
}: let
  node_file = base_config + "/node";
  has_node = builtins.pathExists node_file;
  node_file_content = builtins.readFile node_file;
  bun-pkgs = import bun {system = pkgs.system;};
  node_pkg = with pkgs;
    {
      "" = nodejs;
      "\n" = nodejs;
      "16\n" = nodejs_16;
      "18\n" = nodejs_18;
      "20\n" = nodejs_20;
    }
    ."${node_file_content}";
in {
  pkgs-list =
    [bun-pkgs.bun]
    ++ (
      if has_node
      then [node_pkg]
      else [pkgs.nodejs]
    );
}
