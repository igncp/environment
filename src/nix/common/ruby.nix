{
  pkgs,
  base-config,
}: let
  ruby_file = base-config + "/ruby";
  has_ruby = builtins.pathExists ruby_file;
  has_rbenv = builtins.pathExists (base-config + "/rbenv");
  ruby_file_content =
    if has_ruby
    then builtins.readFile ruby_file
    else "";
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
    else [ruby_pkg] ++ extra_pkgs
  );
}
