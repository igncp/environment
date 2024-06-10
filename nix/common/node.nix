{
  base_config,
  lib,
  pkgs,
}: let
  node_file = base_config + "/node";
  nodenv_file = base_config + "/nodenv";

  has_node = builtins.pathExists node_file;
  has_nodenv = builtins.pathExists nodenv_file;

  has_yarn_berry = builtins.pathExists (base_config + "/yarn-berry");
  defalt_node = pkgs.nodejs_22;

  node_file_content = builtins.readFile node_file;
  node_pkg = with pkgs;
    {
      "" = defalt_node;
      "\n" = defalt_node;
      "16\n" = nodejs_16;
      "18\n" = nodejs_18;
      "20\n" = nodejs_20;
      "22\n" = defalt_node;
    }
    ."${node_file_content}";
in {
  pkgs-list =
    [pkgs.bun]
    ++ (
      if has_nodenv
      then [pkgs.nodenv]
      else if has_node
      then [node_pkg]
      else [defalt_node]
    )
    ++ (
      if has_yarn_berry
      then [pkgs.yarn-berry]
      else []
    );
}
