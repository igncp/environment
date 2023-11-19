{pkgs}: let
  rust-pkgs = import ./common/rust.nix {inherit pkgs;};
in {
  # This devShell is used currently to build some rust packages, it
  # should not be loaded with `direnv` to avoid the extra loading time
  # every time changing to this dir (which happens quite often)
  default = pkgs.mkShell {
    packages = [] ++ rust-pkgs.pkgs-list;
  };
  solana = pkgs.mkShell {
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    packages = with pkgs; [rustup pkgconfig udev clang protobuf];
  };
}
