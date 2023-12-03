{pkgs}: let
  rust-config = import ./common/rust.nix {inherit pkgs;};
  protobuf-pkgs = with pkgs; [
    buf # https://github.com/bufbuild/buf
    protobuf
  ];
in {
  cli-extra = pkgs.mkShell {
    packages = with pkgs; [
      aria2 # https://github.com/aria2/aria2
      bandwhich # https://github.com/imsnif/bandwhich
      bats # https://github.com/sstephenson/bats
      bc
      btop # https://github.com/aristocratos/btop
      csvq # https://github.com/mithrandie/csvq
      ctop # https://github.com/bcicen/ctop
      dasel # https://github.com/TomWright/dasel
      dig
      doctl # https://github.com/digitalocean/doctl
      dogdns # https://github.com/ogham/dog
      duf # https://github.com/muesli/duf
      exiftool # https://github.com/exiftool/exiftool
      ffmpeg
      graphviz # https://gitlab.com/graphviz/graphviz
      hurl # https://github.com/Orange-OpenSource/hurl
      hyperfine # https://github.com/sharkdp/hyperfine
      mitmproxy # https://github.com/mitmproxy/mitmproxy
      mkcert # https://github.com/FiloSottile/mkcert
      pandoc # https://github.com/jgm/pandoc
      pastel # https://github.com/sharkdp/pastel
      procs # https://github.com/dalance/procs
      ranger # https://github.com/ranger/ranger
      redis # For `redis-cli` (to complement `iredis`) - https://redis.io/docs/ui/cli/
      speedtest-cli # https://github.com/sivel/speedtest-cli
      tre-command # https://github.com/dduan/tre
    ];
  };
  cosmos = pkgs.mkShell {
    packages = with pkgs; [clang protobuf-pkgs];
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
