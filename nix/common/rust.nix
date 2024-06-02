{
  pkgs,
  base_config,
}: let
  rust_file = base_config + "/rust";
  has_rust = builtins.pathExists rust_file;
in rec {
  pkgs-list = with pkgs;
    [openssl openssl.dev pkg-config libiconv rustup]
    ++ (
      if system == "aarch64-darwin"
      then [
        pkgs.darwin.apple_sdk.frameworks.AppKit
        pkgs.darwin.apple_sdk.frameworks.Security
      ]
      else []
    );
  pkgs-list-conditional =
    if has_rust
    then pkgs-list
    else [];
  shellHook = ''
    PATH="$HOME/.rustup/bin:$PATH"

    if [ -z "$(rustup component list | grep analy | grep install || true)" ]; then
      rustup component add rust-analyzer
    fi
  '';
}
