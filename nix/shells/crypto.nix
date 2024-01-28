{pkgs}: let
  rust-config = import ../common/rust.nix {inherit pkgs;};
  protobuf-pkgs = with pkgs; [
    buf # https://github.com/bufbuild/buf
    protobuf
  ];
in {
  cosmos = pkgs.mkShell {
    packages = with pkgs; [clang protobuf-pkgs];
  };
  solana = pkgs.mkShell {
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    shellHook = rust-config.shellHook;
    packages = with pkgs;
      [pkg-config]
      ++ protobuf-pkgs
      ++ rust-config.pkgs-list
      ++ (
        if system == "aarch64-darwin"
        then []
        else [udev]
      );
  };
}
