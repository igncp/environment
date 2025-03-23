{pkgs ? import <nixpkgs> {}}: let
  content = import ./site.nix {inherit pkgs;};
in let
  serveSite = pkgs.writeShellScriptBin "startServer" ''
    # -F = do not fork
    # -p = port
    # -r = content root
    echo "Running server: visit http://localhost:8000/example/index.html"
    # See how we reference the content derivation by `${content}`
    ${pkgs.webfs}/bin/webfsd -F -p 8000 -r ${content}
  '';
in
  pkgs.stdenv.mkDerivation {
    name = "server-environment";
    shellHook = ''
      ${serveSite}/bin/startServer
    '';
  }
