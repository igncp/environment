{pkgs}: {
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
  shellHook = ''
    PATH="$HOME/.rustup/bin:$PATH"

    if [ -z "$(rustup component list | grep analy | grep install || true)" ]; then
      rustup component add rust-analyzer
    fi
  '';
}
