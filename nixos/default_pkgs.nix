{pkgs, ...}:
let
  has_gh = builtins.pathExists /home/igncp/development/environment/project/.config/cli-gh;
in {
  default_pkgs = with pkgs; [
    ack
    age
    alejandra
    bat
    cacert
    dbus
    diesel-cli
    direnv
    firefox
    gcc
    git
    gnupg
    go
    graphviz
    htop
    hurl
    jq
    libiconv
    lshw
    lsof
    mitmproxy
    moreutils
    ncdu
    neofetch
    neovim
    nmap
    nodejs
    openssl
    pkgconfig
    python3
    python3.pkgs.pip
    ranger
    rustup
    rustup
    silver-searcher
    sqlite
    tailscale
    taskwarrior
    tmux
    tree
    unzip
    valgrind
    vim
    vnstat
    wasm-pack
    wget
    yq
    zip
    zsh
  ]
  ++ (if has_gh then [ pkgs.gh ] else []);
}
