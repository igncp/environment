{
  pkgs,
  base_config,
}: let
  ruby_file = base_config + "/ruby";
  has_ruby = builtins.pathExists ruby_file;
  has_rbenv = builtins.pathExists (base_config + "/rbenv");
  ruby_file_content = builtins.readFile ruby_file;
  ruby_pkg = with pkgs;
    {
      "" = ruby;
      "\n" = ruby;
      "2_7\n" = ruby_2_7;
    }
    ."${ruby_file_content}";
in {
  pkgs-list = (
    if has_rbenv
    then [pkgs.rbenv pkgs.libyaml pkgs.zlib]
    else if has_ruby
    then [ruby_pkg]
    else []
  );
}
