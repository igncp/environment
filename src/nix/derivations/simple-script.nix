{pkgs}: let
  serveSite = pkgs.writeShellScriptBin "startServer" ''
    echo "Running server: visit http://localhost:8000/example/index.html"
  '';
in
  pkgs.stdenv.mkDerivation {
    name = "startServer";
    src = serveSite;
    installPhase = ''
      mkdir -p $out/bin
      cp $src/bin/startServer $out/bin/startServer
    '';
  }
