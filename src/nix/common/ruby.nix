{
  pkgs,
  env-config,
}: let
  extra_pkgs = [];
  ruby_pkg = with pkgs;
    {
      "" = ruby;
      "\n" = ruby;
      "2_7\n" = ruby_2_7;
    }
    ."${env-config.ruby}";
in {
  pkgs-list = (
    if env-config.has-rbenv
    then with pkgs; [rbenv pkgs.libyaml zlib] ++ extra_pkgs
    else [ruby_pkg] ++ extra_pkgs
  );
}
