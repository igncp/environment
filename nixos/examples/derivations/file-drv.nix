{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  name = "basic-file-derivation";
  src = ./source;
  installPhase = ''
    mkdir $out
    cp -rv $src/* $out
  '';
}
