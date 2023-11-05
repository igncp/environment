{pkgs}: {
  pkgs-list = with pkgs; [openssl openssl.dev pkgconfig libiconv rustup];
}
