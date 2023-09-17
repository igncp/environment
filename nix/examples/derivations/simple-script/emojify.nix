# https://www.sam.today/blog/derivations-102-learning-nix-pt-4
{pkgs ? import <nixpkgs> {}}: let
  emojify = let
    version = "2.0.0";
  in
    pkgs.stdenv.mkDerivation {
      name = "emojify-${version}";
      src = pkgs.fetchFromGitHub {
        owner = "mrowa44";
        repo = "emojify";
        rev = "${version}";
        sha256 = "0zhbfxabgllpq3sy0pj5mm79l24vj1z10kyajc4n39yq8ibhq66j";
      };

      installPhase = ''
        mkdir -p $out/bin
        cp emojify $out/bin/
        chmod +x $out/bin/emojify
      '';
    };
in
  pkgs.stdenv.mkDerivation {
    name = "emojify-environment";
    buildInputs = [emojify];
  }
