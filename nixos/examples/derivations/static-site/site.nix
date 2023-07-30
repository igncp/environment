# https://www.sam.today/blog/derivations-102-learning-nix-pt-4
{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "example-website-content";

  src = pkgs.fetchFromGitHub {
    owner = "jekyll";
    repo = "example";
    rev = "5eb1b902ca3bda6f4b50d4cfcdc7bc0097bac4b7";
    sha256 = "1jw35hmgx2gsaj2ad5f9d9ks4yh601wsxwnb17pmb9j02hl3vgdm";
  };

  installPhase = ''
    export JEKYLL_ENV=production
    ${pkgs.jekyll}/bin/jekyll build --destination $out/example
  '';
}
