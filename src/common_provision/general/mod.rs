use std::path::Path;

use crate::base::{config::Config, system::System, Context};

use self::{
    diagrams::setup_diagrams, fzf::run_fzf, git::run_git, gpg::setup_gpg, hashi::setup_hashi,
    htop::run_htop, network::setup_network, pi_hole::setup_pi_hole, python::run_python,
    shellcheck::setup_shellcheck, taskwarrior::setup_taskwarrior, tmux::setup_tmux,
};

mod diagrams;
mod fzf;
mod git;
mod gpg;
mod hashi;
mod htop;
mod network;
mod pi_hole;
mod python;
mod shellcheck;
mod taskwarrior;
mod tmux;

pub fn run_general(context: &mut Context) {
    System::run_bash_command(
        r###"
mkdir -p $HOME/.scripts/toolbox

while IFS= read -r -d '' FILE_PATH; do
  FILE_NAME=$(basename "$FILE_PATH")
  if [ ! -f "$HOME/.scripts/toolbox/$FILE_NAME" ]; then
    (cd "$FILE_PATH" \
      && cargo build --release --jobs 1 \
      && cp $HOME/.scripts/cargo_target/release/"$FILE_NAME" $HOME/.scripts/toolbox/)
  fi
done < <(find ~/development/environment/unix/scripts/toolbox -maxdepth 1 -mindepth 1 -type d -print0)

while IFS= read -r -d '' FILE_PATH; do
  FILE_NAME=$(basename "$FILE_PATH")
  if [ ! -f "$HOME/.scripts/cargo_target/release/$FILE_NAME" ]; then
    (cd "$FILE_PATH" \
      && cargo build --release --jobs 1)
  fi
done < <(find ~/development/environment/unix/scripts/misc -maxdepth 1 -mindepth 1 -type d -print0)

# This increases re-compilation times but these dirs can get very large
rm -rf ~/.scripts/cargo_target/release/deps
rm -rf ~/.scripts/cargo_target/release/build
rm -rf ~/.scripts/cargo_target/debug

if [ ! -f ~/.ssh/config ]; then
  mkdir -p ~/.ssh
  cp ~/development/environment/unix/config-files/ssh-client-config ~/.ssh/config
fi
"###,
    );

    std::fs::create_dir_all(context.system.get_home_path(".scripts/toolbox")).unwrap();
    std::fs::create_dir_all(context.system.get_home_path("logs")).unwrap();

    if !context.system.is_nixos() {
        context
            .system
            .install_system_package("base-devel", Some("make"));
    }

    context.system.install_system_package("curl", None);
    context
        .system
        .install_system_package("dnsutils", Some("dig"));
    context.system.install_system_package("git", None);
    context.system.install_system_package("jq", None);
    context.system.install_system_package("lsof", None);
    context.system.install_system_package("ncdu", None);
    context.system.install_system_package("neofetch", None);
    context.system.install_system_package("nmap", None);
    context.system.install_system_package("ranger", None);
    context.system.install_system_package("rsync", None);
    context.system.install_system_package("tree", None);
    context.system.install_system_package("unzip", None);
    context.system.install_system_package("wget", None);
    context.system.install_system_package("zip", None);

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r#"
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

export EDITOR=vim
export PATH="$PATH:$HOME/development/environment/unix/scripts"
export PATH="$PATH:$HOME/development/environment/unix/scripts/bootstrap"
export PATH="$PATH:$HOME/.local/bin"
"#,
    );

    if !Path::new(&context.system.get_home_path(".git-prompt")).exists() {
        System::run_bash_command(
            r###"
if type pacman > /dev/null 2>&1 ; then
  sudo pacman -S --noconfirm bash-completion
fi
curl -k -o ~/.git-prompt https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
"###,
        );
    }

    context.files.append(
        &context.system.get_home_path(".shell_sources"),
        r#"
source_if_exists() {
  FILE_PATH=$1
  if [ -f $FILE_PATH ]; then source $FILE_PATH; fi
}

source_if_exists ~/.shell_aliases
source_if_exists ~/.git-prompt
"#,
    );

    if !Path::new(&context.system.get_home_path(".config/up/up.sh")).exists() {
        System::run_bash_command(
            r###"
curl -k --create-dirs -o ~/.config/up/up.sh https://raw.githubusercontent.com/shannonmoeller/up/master/up.sh
"###,
        );
    }

    context.files.appendln(
        &context.system.get_home_path(".shell_sources"),
        "source_if_exists ~/.config/up/up.sh",
    );

    setup_tmux(context);

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias ag="ag --hidden  --color-match 7"
alias agg='ag --hidden --ignore node_modules --ignore .git'
alias cp="cp -r"
alias htop="htop --no-color"
alias l="less -i"
alias ll="ls -lah --color=always"
alias lsblk="lsblk -f"
alias mkdir="mkdir -p"
alias r="ranger"
alias rm="rm -rf"
alias svim="sudo vim"
alias tree="tree -a"
alias wget="wget -c"

alias ca="~/.scripts/cargo_target/release/canto-cli"
alias gob="git checkout -b"

alias Lsblk="lsblk -f | less -S"
Diff() { diff --color=always "$@" | less -r; }
DisplayFilesConcatenated(){ xargs tail -n +1 | sed "s|==>|\n\n\n\n\n$1==>|; s|<==|<==\n|" | $EDITOR -; }
FileSizeCreate() { head -c "$1" /dev/urandom > "$2"; } # For example: FileSizeCreate 1GB /tmp/foo
FindLinesJustInFirstFile() { comm -23 <(sort "$1") <(sort "$2"); }
FindSortDate() { find "$@" -printf "%T@ %Tc %p\n" | sort -nr; }
GetProcessUsingPort(){ fuser $1/tcp 2>&1 | grep -oE '[0-9]*$'; }
GetProcessUsingPortAndKill(){ fuser $1/tcp 2>&1 | grep -oE '[0-9]*$' | xargs -I {} kill {}; }
KillPsAux() { awk '{ print $2 }' | xargs -I{} kill "$@" {}; }
LsofDir() { lsof +D $1; } # It uses `+` instead of `-`
LsofNetwork() { lsof -i; }
LsofPort() { lsof -i TCP:$1; }
LsofProcess() { lsof -p $1; } # It expects the PID
RandomFile() { find "$1" -type f | shuf -n 1; }
RandomLine() { sort -R "$1" | head -n 1; }
# will not catch `'` so can wrap generated texts with single quotes
RandomStrGenerator() { tr -dc 'A-Za-z0-9!"#$%&()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c "$1"; echo; }
SedLines() { if [ "$#" -eq 1 ]; then sed -n "$1,$1p"; else sed -n "$1,$2p"; fi; }
TopCPU()    { ps aux | sort -nr -k 3 | head "$@" | sed -e 'G;G;'; } # e.g. TopCPU -n 5 | less -S
TopMemory() { ps aux | sort -nr -k 4 | head "$@" | sed -e 'G;G;'; } # e.g. TopMemory -n 5 | less -S
USBClone() { if [ -z "$I" ] || [ -z "$O" ]; then echo "Missing params"; return; fi; dd if=$I of=$O bs=1G count=10 status=progress; } # Example: I=/dev/sdb O=/dev/sdc USBClone
Vidir() { vidir -v -; }
VidirFind() { find $@ | vidir -v -; }
VisudoUser() { sudo env EDITOR=vim visudo -f /etc/sudoers.d/$1; }

alias SSHAgent='eval `ssh-agent`'
SSHGeneratePemPublicKey() { FILE=$1; ssh-keygen -f "$FILE" -e -m pem; }
SSHGenerateStrongKey() { FILE="$1"; ssh-keygen -t ed25519 -f "$FILE"; }
alias SSHListLocalForwardedPorts='ps x -ww -o pid,command | ag ssh | grep --color=never localhost'
SSHForwardPortLocal() { ssh -fN -L "$1":localhost:"$1" ${@:2}; } # SSHForwardPort 1234 192.168.1.40
alias SSHDConfig='sudo sshd -T'
SSHListConnections() { sudo netstat -tnpa | grep 'ESTABLISHED.*sshd'; }

alias AliasesReload='source ~/.shell_aliases'
alias CleanNCurses='stty sane;clear;'
alias EditProvision="(cd ~/development/environment && $EDITOR src/main.rs && cargo run --release)"
alias FDisk='sudo fdisk /dev/sda'
alias FilterLeaf=$'sort -r | awk \'a!~"^"$0{a=$0;print}\' | sort'
alias FlatpackInit='flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo'
alias GeoInfo='curl -s ipinfo.io | jq .'
alias HierarchyManual='man hier'
alias IPPublic='curl ifconfig.co'
alias KillAllTmux='killall /usr/bin/tmux || true ; killall tmux || true ; killall $(which tmux) || true'
alias LastColumn="awk '{print "'$NF'"}'"
alias PathShow='echo $PATH | tr ":" "\n" | sort | uniq | less'
alias Provision="(cd ~/development/environment && cargo run --release)"
alias PsTree='pstree -pTUl | less -S'
alias RsyncDelete='rsync -rhv --delete' # remember to add a slash at the end of source (dest doesn't matter)
alias ShellChangeToBash='chsh -s /bin/bash; exit'
alias SocketSearch='sudo ss -lntup'
alias TreeDir='tree -d'
alias Visudo='sudo env EDITOR=vim visudo'
alias Xargs='xargs -I{}'
alias YoutubeSubtitles='yt-dlp --all-subs --skip-download'

alias CrontabUser='crontab -e'
alias CrontabRoot='sudo EDITOR=vim crontab -e'

alias Headers='curl -I' # e.g. Headers google.com
alias NmapLocal='sudo nmap -sn 192.168.1.0/24 > /tmp/nmap-result && sed -i "s|Nmap|\nNmap|" /tmp/nmap-result && less /tmp/nmap-result'
alias Ports='sudo netstat -tulanp'
alias NetstatConnections='netstat -nputw'
alias AnsiColorsRemove="sed 's/\x1b\[[0-9;]*m//g'"

WorktreeClone() { git clone --bare "$1" .bare; echo "gitdir: ./.bare" > .git; }

alias n="$HOME/.scripts/cargo_target/release/n"

ConfigProvisionList() {
    if [ -n "$1" ]; then
        ~/.scripts/cargo_target/release/provision_choose_config "$1"
        return
    fi
    ~/.scripts/cargo_target/release/provision_choose_config && Provision
}

CargoGenerateClean() {
    BIN_NAME=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[].targets[] | select( .kind | map(. == "bin") | any ) | .name')
    CARGO_TARGET_DIR=target cargo build --release && mv target/release/"$BIN_NAME" . && rm -rf target
    echo "Binary '$BIN_NAME' built and moved to current directory"
}

CargoRunClean() {
    DIR=$1 ; COMMAND=$(basename $DIR)
    (cd $DIR && CargoGenerateClean )
    $DIR/$COMMAND
}

CargoDevGenerate() {
    BIN_NAME=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[].targets[] | select( .kind | map(. == "bin") | any ) | .name')
    CARGO_TARGET_DIR=target cargo build && mv target/debug/"$BIN_NAME" .
    echo "Binary '$BIN_NAME' built and moved to current directory"
}
    "###);

    // https://github.com/TomWright/dasel
    // https://daseldocs.tomwright.me/
    if !context.system.get_has_binary("dasel") && !context.system.is_nixos() {
        if context.system.is_mac() {
            System::run_bash_command("brew install dasel");
        } else if context.system.is_linux() {
            System::run_bash_command(
                r###"
FILTER_OPT="linux_amd64"
DASEL_URL="$(curl -sSLf https://api.github.com/repos/tomwright/dasel/releases/latest | grep browser_download_url | grep "$FILTER_OPT" | grep -v '\.gz' | cut -d\" -f 4)"
curl -sSLf "$DASEL_URL" -L -o dasel && sudo chmod +x dasel
sudo mv ./dasel /usr/local/bin/dasel
"###,
            );
        }
    }

    if context.system.is_linux() {
        if !Path::new(&context.system.get_home_path(".dircolors")).exists() {
            System::run_bash_command(
                r###"
dircolors -p > ~/.dircolors
COLOR_ITEMS=(FIFO OTHER_WRITABLE STICKY_OTHER_WRITABLE CAPABILITY SETGID SETUID ORPHAN CHR BLK)
for COLOR_ITEM in "${COLOR_ITEMS[@]}"; do
    sed -i 's|^'"$COLOR_ITEM"' .* #|'"$COLOR_ITEM"' 01;35 #|' ~/.dircolors
done
"###,
            );
        }

        context.files.appendln(
            &context.system.get_home_path(".shellrc"),
            r#"eval "$(dircolors ~/.dircolors)""#,
        );
    }

    let notice_file = Config::get_config_file_path(&context.system, ".config/ssh-notice-color");

    if !Path::new(&notice_file).exists() {
        context.files.append(&notice_file, "cyan");
        context.write_file(&notice_file, true);
    }

    context.files.appendln(
        &context.system.get_home_path(".shell_aliases"),
        r#"MsgFmtPo() { FILE_NO_EXT="$(echo $1 | sed 's|.po$||')" ; msgfmt -o "$1".mo "$1".po ; }"#,
    );

    // Only for bash, zsh uses `dirs -v` and `cd -[tab]`
    if !Path::new(&context.system.get_home_path(".acd_func")).exists() {
        System::run_bash_command(
            r###"
curl -k -o ~/.acd_func \
    https://raw.githubusercontent.com/djoot/all-bash-history/master/acd_func.sh
"###,
        );
        context.files.appendln(
            &context.system.get_home_path(".bashrc"),
            r#"source "$HOME"/.acd_func"#,
        );
    }

    context.files.append(
        &context.system.get_home_path(".bash_profile"),
        r###"
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
"###,
    );

    context.files.append(
        &context.system.get_home_path(".bashrc"),
        r###"
if [ -z "$PS1" ]; then
  # prompt var is not set, so this is *not* an interactive shell (e.g. using scp)
  return
fi

# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# prevent the terminal from hanging on ctrl+s
# although it can be recovered with ctrl+q
stty -ixon

export HISTCONTROL=ignoreboth:erasedups
export EDITOR=vim

source ~/.shellrc
source ~/.shell_sources

PS1='$(~/.scripts/cargo_target/release/ps1 bash "$(jobs)")'
"###,
    );

    context.files.append(
        &context.system.get_home_path(".inputrc"),
        r###"
set mark-symlinked-directories on
set show-all-if-ambiguous on

C-h:unix-filename-rubout
C-k:edit-and-execute-command

Control-x: " fg\n"
Control-}: " | less -SR\n"

set show-all-if-ambiguous on

# How to get these characters:
# - run `sed -n l`
# - type combination (it only works for some, like ctrl + something)
# - copy it here, but replace ^[ with  (ctrl-v ctrl-[ in insert mode)
"[1;5A":menu-complete # ctrl-up
"[1;5B":menu-complete-backward # ctrl-down
"###,
    );

    if context.system.is_linux() && !context.system.is_nixos() {
        System::run_bash_command(
            r###"
echo 'LANG=en_US.UTF-8' > /tmp/locale.conf
sudo mv /tmp/locale.conf /etc/locale.conf

if [[ ! -z $(sudo ufw status | grep inactive) ]]; then
    sudo ufw allow ssh
    sudo ufw --force enable
    sudo systemctl enable --now ufw
fi
"###,
        );

        // To mute/unmute in GUI press M
        context
            .system
            .install_system_package("alsa-utils", Some("alsamixer"));

        if !context.system.is_nixos() {
            // UFW
            context.system.install_system_package("ufw", None);
        }

        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
alias UFWStatus='sudo ufw status numbered' # numbered is useful for insert / delete
alias UFWLogging='sudo ufw logging on'
UFWDelete() { sudo ufw status numbered ; sudo ufw --force delete $1; sudo ufw status numbered; }
alias UFWBlocked="sudo journalctl | grep -i ufw | tail -f" # For better findings, can use `grep -v -f /tmp/some_file` with some patterns to ignore
UFWAllowOutIPPort() { sudo ufw allow out from any to $1 port $2; }
UFWInit() {
    sudo ufw default deny outgoing; sudo ufw default deny incoming;
    sudo ufw allow out to any port 80; sudo ufw allow out to any port 443;
}
"###,
        );
    }

    context
        .system
        .install_system_package("moreutils", Some("vidir"));
    context
        .system
        .install_system_package("net-tools", Some("netstat"));

    context.files.appendln(
        &context.system.get_home_path(".bashrc"),
        "complete -cf sudo",
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
# https://stackoverflow.com/a/22625150
CurlMeasureTime() {
  cat > /tmp/curl_measure_time.txt <<"EOF2"
  time_namelookup:  %{time_namelookup}s\n
        time_connect:  %{time_connect}s\n
     time_appconnect:  %{time_appconnect}s\n
    time_pretransfer:  %{time_pretransfer}s\n
       time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
                     ----------\n
          time_total:  %{time_total}s\n
EOF2
  curl -w "@/tmp/curl_measure_time.txt" -o /dev/null -s $@
}
"###,
    );

    if !context.system.is_nix_provision {
        // Used to run a local server with https
        context.system.install_system_package("mkcert", None);
        // To install the root CA under NixOS:
        // - `mkcert localhost 127.0.0.1 ::1`
        // - Open in Chrome: `chrome://settings/certificates` under the "Authorities tab
        // - Import the root CA in ~/.local/share/mkcert
        // - Restart Chrome
        // - Uninstall when done as it can be used to intercept secure traffic (if the root CA
        // shared)
        // - It has the name `org-mkcert development CA`
    }

    setup_gpg(context);
    run_git(context);
    run_fzf(context);
    run_htop(context);
    run_python(context);
    setup_taskwarrior(context);
    setup_pi_hole(context);
    setup_network(context);
    setup_diagrams(context);
    setup_shellcheck(context);
}

pub fn run_general_end(context: &mut Context) {
    setup_hashi(context);
}
