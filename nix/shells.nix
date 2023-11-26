{pkgs}: let
  rust-config = import ./common/rust.nix {inherit pkgs;};
in {
  cosmos = pkgs.mkShell {
    packages = with pkgs; [clang protobuf];
  };
  load-testing = pkgs.mkShell {
    packages = with pkgs; [vegeta];
    shellHook = ''
      set -a
      Vegeta() { echo foo; }
      set +a
    '';
  };
  rust = pkgs.mkShell {
    packages = rust-config.pkgs-list;
    shellHook = rust-config.shellHook;
  };
  solana = pkgs.mkShell {
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    shellHook = rust-config.shellHook;
    packages = with pkgs;
      [pkgconfig clang protobuf]
      ++ rust-config.pkgs-list
      ++ (
        if system == "aarch64-darwin"
        then []
        else [udev]
      );
  };
}
