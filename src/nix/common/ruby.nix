{
  pkgs,
  base-config,
  env-config,
}: let
  ruby_file = base-config + "/ruby";
  ruby_file_content =
    if env-config.has-ruby
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
    if env-config.has-rbenv
    then with pkgs; [rbenv pkgs.libyaml zlib] ++ extra_pkgs
    else [ruby_pkg] ++ extra_pkgs
  );
}
