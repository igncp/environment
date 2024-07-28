{pkgs}: let
  is_linux =
    (pkgs.system == "x86_64-linux")
    || (pkgs.system == "aarch64-linux")
    || pkgs.system == "armv7l-linux";
in {
  cli-extra = pkgs.mkShell {
    packages = with pkgs;
      [
        aria2 # https://github.com/aria2/aria2
        bandwhich # https://github.com/imsnif/bandwhich
        bats # https://github.com/sstephenson/bats
        bc
        bitwarden-cli # https://github.com/bitwarden/clients
        btop # https://github.com/aristocratos/btop
        csvq # https://github.com/mithrandie/csvq
        ctop # https://github.com/bcicen/ctop
        dasel # https://github.com/TomWright/dasel
        dig
        doctl # https://github.com/digitalocean/doctl
        dogdns # https://github.com/ogham/dog
        duf # https://github.com/muesli/duf
        exiftool # https://github.com/exiftool/exiftool
        graphviz # https://gitlab.com/graphviz/graphviz
        mkcert # https://github.com/FiloSottile/mkcert
        nix-tree # https://github.com/utdemir/nix-tree
        pandoc # https://github.com/jgm/pandoc
        procs # https://github.com/dalance/procs
        ranger # https://github.com/ranger/ranger
        redis # For `redis-cli` (to complement `iredis`) - https://redis.io/docs/ui/cli/
        speedtest-cli # https://github.com/sivel/speedtest-cli
        translate-shell # https://github.com/soimort/translate-shell
        tre-command # https://github.com/dduan/tre
        up # https://github.com/akavel/up
        websocat # https://github.com/vi/websocat
      ]
      ++ (
        if is_linux
        then
          with pkgs;
            [
              etcd # https://github.com/etcd-io/etcd/tree/main/etcdctl # Marked as broken in macOS
              valgrind
            ]
            ++ (lib.optional has_cli_openvpn pkgs.update-resolv-conf)
        else []
      );
  };
}
