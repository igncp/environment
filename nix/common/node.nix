{
  base_config,
  lib,
  pkgs,
  unstable_pkgs,
}: let
  node_file = base_config + "/node";
  has_node = builtins.pathExists node_file;
  has_yarn_berry = builtins.pathExists (base_config + "/yarn-berry");

  node_file_content = builtins.readFile node_file;
  node_pkg = with unstable_pkgs;
    {
      "" = nodejs_20;
      "\n" = nodejs_20;
      "16\n" = nodejs_16;
      "18\n" = nodejs_18;
      "20\n" = nodejs_20;
    }
    ."${node_file_content}";
in {
  pkgs-list =
    [unstable_pkgs.bun]
    ++ (
      if has_node
      then [node_pkg]
      else [unstable_pkgs.nodejs_20]
    )
    ++ (
      if has_yarn_berry
      then [unstable_pkgs.yarn-berry]
      else []
    );
}
