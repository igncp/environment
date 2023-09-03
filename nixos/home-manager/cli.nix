{
  base_config,
  unstable_pkgs,
}: {
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    alejandra # https://github.com/kamadorueda/alejandra
    bandwhich # https://github.com/imsnif/bandwhich
    bat # https://github.com/sharkdp/bat
    btop # https://github.com/aristocratos/btop
    ctop # https://github.com/bcicen/ctop
    dasel # https://github.com/TomWright/dasel
    delta # https://github.com/dandavison/delta
    direnv # https://github.com/direnv/direnv
    dogdns # https://github.com/ogham/dog
    duf # https://github.com/muesli/duf
    entr # https://github.com/eradman/entr
    exiftool # https://github.com/exiftool/exiftool
    fd # https://github.com/sharkdp/fd
    fzf # https://github.com/junegunn/fzf
    gh # https://github.com/cli/cli
    graphviz # https://gitlab.com/graphviz/graphviz
    htop # https://github.com/htop-dev/htop
    hurl # https://github.com/Orange-OpenSource/hurl
    hyperfine # https://github.com/sharkdp/hyperfine
    iredis # https://github.com/laixintao/iredis
    jq # https://github.com/jqlang/jq
    mitmproxy # https://github.com/mitmproxy/mitmproxy
    mkcert # https://github.com/FiloSottile/mkcert
    ncdu
    neofetch # https://github.com/dylanaraps/neofetch
    pandoc # https://github.com/jgm/pandoc
    pastel # https://github.com/sharkdp/pastel
    pgcli # https://github.com/dbcli/pgcli
    procs # https://github.com/dalance/procs
    ranger # https://github.com/ranger/ranger
    rsync # https://github.com/WayneD/rsync
    sad # https://github.com/ms-jpq/sad
    scc # https://github.com/boyter/scc
    sd # https://github.com/chmln/sd
    silver-searcher # https://github.com/ggreer/the_silver_searcher
    speedtest-cli # https://github.com/sivel/speedtest-cli
    taskwarrior # https://github.com/GothenburgBitFactory/taskwarrior
    tmux # https://github.com/tmux/tmux
    tre-command # https://github.com/dduan/tre
    unstable_pkgs.age # https://github.com/FiloSottile/age
    unstable_pkgs.ast-grep # https://github.com/chmln/sd
    unzip
    wget
    yq # https://github.com/mikefarah/yq
    zip
  ];
}
