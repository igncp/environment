{
  pkgs,
  base-config,
}: let
  ruby_file = base-config + "/ruby";
  has_ruby = builtins.pathExists ruby_file;
  has_rbenv = builtins.pathExists (base-config + "/rbenv");
  ruby_file_content = builtins.readFile ruby_file;
  extra_pkgs = [];
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
    then with pkgs; [rbenv pkgs.libyaml zlib] ++ extra_pkgs
    else if has_ruby
    then [ruby_pkg] ++ extra_pkgs
    else []
  );
}
