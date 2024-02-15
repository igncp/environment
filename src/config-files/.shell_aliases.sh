alias ag="ag --hidden  --color-match 7"
alias agg='ag --hidden --ignore node_modules --ignore .git'
alias b='bash'
alias cp="cp -r"
alias di='SudoNix dua interactive'
alias dp="docker ps -a"
alias f='fd --type f .'
alias h="sad"
alias htop="htop --no-color"
alias l="less"
alias ll="ls -lahv --color=always"
alias lsblk="lsblk -f"
alias m="mkdir -p"
alias rm="rm -rf"
alias rsr="rsync --remove-source-files -av --progress"
alias s='sd'
alias ta="tmux attach"
alias tree="tree -a"
alias up='up -o /tmp/up-result.sh'
alias wget="wget -c"

S() { fd --type f . $1 | sad "${@:2}"; }

dl() {
  CONTAINER="$(docker ps -a | grep $1 | awk '{ print $1; }' || true)"
  echo "$CONTAINER"
  if [ "$(echo $CONTAINER | wc -l)" = "1" ]; then
    docker logs $CONTAINER "${@:2}"
  else
    docker logs "$@"
  fi
}

de() {
  CONTAINER="$(docker ps | grep $1 | awk '{print $1}' || true)"
  if [ -n "$CONTAINER" ]; then docker exec -it $CONTAINER /bin/bash; fi
}

drb() {
  docker run -it --rm "${@:2}" $1 /bin/bash
}

alias ca="~/.scripts/cargo_target/release/canto-cli"

alias Lsblk="lsblk -f | less -S"
Diff() { diff --color=always "$@" | less -r; }
DisplayFilesConcatenated() { xargs tail -n +1 | sed "s|==>|\n\n\n\n\n$1==>|; s|<==|<==\n|" | $EDITOR -; }
FileSizeCreate() { head -c "$1" /dev/urandom >"$2"; } # For example: FileSizeCreate 1GB /tmp/foo
FindLinesJustInFirstFile() { comm -23 <(sort "$1") <(sort "$2"); }
FindSortDate() { find "$@" -printf "%T@ %Tc %p\n" | sort -nr; }
GetProcessUsingPort() { fuser $1/tcp 2>&1 | grep -oE '[0-9]*$'; }
GetProcessUsingPortAndKill() { fuser $1/tcp 2>&1 | grep -oE '[0-9]*$' | xargs -I {} kill {}; }
KillPsAux() { awk '{ print $2 }' | xargs -I{} kill "$@" {}; }
LsofDir() { lsof +D $1; } # It uses `+` instead of `-`
LsofNetwork() { lsof -i; }
LsofPort() { lsof -i TCP:$1; }
LsofProcess() { lsof -p $1; } # It expects the PID
RandomFile() { find "$1" -type f | shuf -n 1; }
RandomLine() { sort -R "$1" | head -n 1; }
# will not catch `'` so can wrap generated texts with single quotes
RandomStrGenerator() {
  tr -dc 'A-Za-z0-9!"#$%&()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c "$1"
  echo
}
SedLines() { if [ "$#" -eq 1 ]; then sed -n "$1,$1p"; else sed -n "$1,$2p"; fi; }
SortJSON() { cat "$1" | jq -S | sponge "$1"; }
TopCPU() { ps aux | sort -nr -k 3 | head "$@" | sed -e 'G;G;'; }    # e.g. TopCPU -n 5 | less -S
TopMemory() { ps aux | sort -nr -k 4 | head "$@" | sed -e 'G;G;'; } # e.g. TopMemory -n 5 | less -S
USBClone() {
  if [ -z "$I" ] || [ -z "$O" ]; then
    echo "Missing params"
    return
  fi
  dd if=$I of=$O bs=1G count=10 status=progress
} # Example: I=/dev/sdb O=/dev/sdc USBClone
Vidir() { vidir -v -; }
VidirFind() { find $@ | vidir -v -; }
VisudoUser() { sudo env EDITOR=vim visudo -f /etc/sudoers.d/$1; }
alias ClipboardSSHSend="clipboard_ssh send"
alias HostClipboardSSH="clipboard_ssh host"

alias Vpn='(cd ~/development/environment && bash src/scripts/misc/vpn.sh)'

if type ffmpeg >/dev/null 2>&1; then
  FfmpegSubs() {
    if [ -z "$1" ]; then
      echo "缺少影片路徑" && exit 1
    fi

    # 第一個參數是影片的檔案路徑
    ffmpeg -i $1 -map 0:s:${2:-0} ${3:-$1}.srt
  }
fi

# Cross-platform (including remote VM) function which accepts text from a pipe
ClipboardCopyPipe() {
  read INPUT
  if [ -z "$INPUT" ]; then return; fi
  echo "$INPUT" | clipboard_ssh send
}

# Sample of alias using ClipboardCopyPipe and bitwarden
alias BWAliasExample=$'bw list items --search myapp | jq \'.[0].login.password\' -r | ClipboardCopyPipe'

alias SSHAgent='eval `ssh-agent`'
SSHGeneratePemPublicKey() {
  FILE=$1
  ssh-keygen -f "$FILE" -e -m pem
}
SSHGenerateStrongKey() {
  FILE="$1"
  ssh-keygen -t ed25519 -f "$FILE"
}
alias SSHListLocalForwardedPorts='ps x -ww -o pid,command | ag ssh | grep --color=never localhost'
SSHForwardPortLocal() { ssh -fN -L "$1":localhost:"$1" ${@:2}; } # SSHForwardPort 1234 192.168.1.40
alias SSHDConfig='sudo sshd -T'
SSHListConnections() { sudo netstat -tnpa | grep 'ESTABLISHED.*sshd'; }

# Example to how to manually add a key with a timeout
SSHExampleConfigure() {
  if [ -n "$(ssh-add -L | grep some_key || true)" ]; then return; fi

  eval $(ssh-agent)
  ssh-add -t 1h ~/.ssh/some_key
}

alias lang='b ~/development/environment/src/scripts/misc/lang.sh'

alias AliasesReload='source ~/.shell_aliases'
alias CleanNCurses='stty sane;clear;'
alias EditProvision="(cd ~/development/environment && $EDITOR src/main.sh && cargo run --release)"
alias FDisk='sudo fdisk /dev/sda'
alias FilterLeaf=$'sort -r | awk \'a!~"^"$0{a=$0;print}\' | sort'
alias FlatpackInit='flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo'
alias FormatProto='clang-format -i'
alias GeoInfo='curl -s ipinfo.io | jq .'
alias HierarchyManual='man hier'
alias IPPublic='curl ifconfig.co'
alias KillAllTmux='(killall /usr/bin/tmux || true ; killall tmux || true ; killall $(which tmux) || true) > /dev/null 2>&1'
alias LastColumn="awk '{print "'$NF'"}'"
alias PathShow='echo $PATH | tr ":" "\n" | sort | uniq | less'
alias Provision="(cd ~/development/environment && bash src/main.sh)"
alias PsTree='pstree -s'
alias RsyncDelete='rsync -rhv --delete' # remember to add a slash at the end of source (dest doesn't matter)
alias ShellChangeToBash='chsh -s /bin/bash; exit'
alias SocketSearch='sudo ss -lntup'
alias SyncProvisionCustom='(cd ~/development/environment && bash src/scripts/copy_custom.sh)'
alias TreeDir='tree -d'
alias Visudo='sudo env EDITOR=vim visudo'
alias Xargs='xargs -I{} '
alias YoutubeSubtitles='yt-dlp --all-subs --skip-download'

alias CrontabUser='crontab -e'
alias CrontabRoot='sudo EDITOR=vim crontab -e'

alias Headers='curl -I' # e.g. Headers google.com
alias Ports='sudo netstat -tulanp'
alias NetstatConnections='netstat -nputw'
alias AnsiColorsRemove="sed 's/\x1b\[[0-9;]*m//g'"

NmapLocal() {
  THIRD_NUM=${1:-1}
  sudo --preserve-env=PATH env nmap -sn "192.168.$THIRD_NUM.0/24" >/tmp/nmap-result
  sed -i "s|Nmap|\nNmap|" /tmp/nmap-result
  less /tmp/nmap-result
}

alias deluge_custom_client='~/.scripts/cargo_target/release/deluge_custom_client'

WorktreeClone() {
  git clone --bare "$1" .bare
  echo "gitdir: ./.bare" >.git
}

n() {
  NOW=$SECONDS
  bash ~/development/environment/src/scripts/misc/n.sh $@
  AFTER=$SECONDS
  PASSED=$(($AFTER - $NOW))

  if [ $PASSED -lt 2 ]; then
    builtin fg
  else
    echo "nvim session: $PASSED"
  fi
}

ConfigProvisionList() {
  INITIAL_SHA=$(find ~/development/environment/project/.config -type f | sort -V | sha256sum | awk '{print $1}')
  /usr/local/bin/environment_scripts/provision_choose_config $@ || return
  AFTER_SHA=$(find ~/development/environment/project/.config -type f | sort -V | sha256sum | awk '{print $1}')
  # Stop if no changes
  if [ "$INITIAL_SHA" = "$AFTER_SHA" ]; then return; fi
  SwitchHomeManager &&
    Provision
}

alias ConfigProvisionListFzf='ConfigProvisionList fzf'

CargoGenerateClean() {
  BIN_NAME=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[].targets[] | select( .kind | map(. == "bin") | any ) | .name')
  CARGO_TARGET_DIR=target cargo build --release && mv target/release/"$BIN_NAME" . && rm -rf target
  echo "Binary '$BIN_NAME' built and moved to current directory"
}

CargoRunClean() {
  DIR=$1
  COMMAND=$(basename $DIR)
  (cd $DIR && CargoGenerateClean)
  $DIR/$COMMAND
}

CargoDevGenerate() {
  BIN_NAME=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[].targets[] | select( .kind | map(. == "bin") | any ) | .name')
  CARGO_TARGET_DIR=target cargo build && mv target/debug/"$BIN_NAME" .
  echo "Binary '$BIN_NAME' built and moved to current directory"
}

alias NixClearSpace=' SwitchHomeManager ; nix-collect-garbage -d && SwitchHomeManager'
alias NixFileEval='nix-instantiate --eval'
alias NixFlakeUpdateInput='nix flake lock --update-input'
alias NixInstallPackage='nix-env -iA'
alias NixListChannels='nix-channel —-list'
alias NixListGenerations="nix-env --list-generations"
alias NixListPackages='nix-env --query "*"'
alias NixRemovePackage='nix-env -e'
alias NixUpdate='nix-env -u && nix-channel --update && nix-env -u'

NixGCRoots() {
  if [ -n "$1" ] && [ -n "$(echo $1 | grep .)" ]; then
    nix-store --gc --print-roots 2>&1 | ag -v removing | ag -v censored | awk '{ print $1; }' |
      ag $1 | xargs -I{} rm -rf {}
  fi

  nix-store --gc --print-roots 2>&1 | ag -v removing | ag -v censored | awk '{ print $1; }'
}

NixListReferrers() {
  # This is useful when copying from dua result
  ITEM="$1"
  if [ -z "$(echo $ITEM | grep -F /nix/store || true)" ]; then
    ITEM="/nix/store$ITEM"
  fi
  nix-store --query --referrers $ITEM
}
NixListClosure() {
  # This is useful when copying from dua result
  ITEM="$1"
  if [ -z "$(echo $ITEM | grep -F /nix/store || true)" ]; then
    ITEM="/nix/store$ITEM"
  fi
  nix-store --query --referrers-closure $ITEM
}
NixPathInfo() {
  # This is useful when copying from dua result
  ITEM="$1"
  if [ -z "$(echo $ITEM | grep -F /nix/store || true)" ]; then
    ITEM="/nix/store$ITEM"
  fi
  nix path-info -Sh $ITEM
}

alias NixDevelop='NIX_SHELL_LEVEL=1 nix develop -c zsh'
alias NixDevelopPath='NIX_SHELL_LEVEL=1 nix develop path:$(pwd) -c zsh'
alias NixDevelopBase='NIX_SHELL_LEVEL=1 nix develop'
alias NixDevelopBasePath='NIX_SHELL_LEVEL=1 nix develop path:$(pwd)'

NixEnvironmentUpgrade() {
  if [ -n "$(ps aux | ag 'tmux[ ]new-session')" ]; then
    echo "You should stop tmux first so there are not nix shells opened"
    return
  fi
  cd ~/development/environment
  nix flake lock --update-input nixpkgs
  nix flake lock --update-input unstable
  nix flake lock --update-input home-manager
  nix flake lock --update-input flake-utils
  NixClearSpace
  echo "You can clear now the garbage roots with: NixGCRoots"
}

alias HomeManagerInitFlake='nix run home-manager/release-23.05 -- init'
alias HomeManagerDeleteGenerations='home-manager expire-generations "-1 second"'

NixSyncInput() {
  if [ -z "$1" ]; then
    echo "Missing input"
    return
  fi
  ENV_INPUT=$(nix flake metadata --json ~/development/environment | jq -r '.locks.nodes."'"$1"'"')
  if [ -z "$ENV_INPUT" ]; then
    echo "Input not found"
    return
  fi
  if [ ! -f flake.lock ]; then
    echo "flake.lock not found"
    return
  fi
  if [ -z "$(cat flake.lock | grep $1)" ]; then
    echo "Input not found in flake.lock"
    return
  fi
  if [ -n "$(pwd | grep 'development.environment')" ]; then
    echo "You can't use this command in the environment repo"
    return
  fi
  cat flake.lock | jq '.nodes."'"$1"'"'" = $ENV_INPUT"'' | sponge flake.lock
}

# The space is important to be able to also run other aliases (not only Nix
# binaries):
# https://linuxhandbook.com/run-alias-as-sudo/
alias SudoNix='sudo --preserve-env=PATH env '

SwitchHomeManager() {
  # Impure is needed for now to read the config
  home-manager switch --impure --flake ~/development/environment/
}

# # To patch a binary interpreter path, for example for 'foo:
# patchelf --set-interpreter /usr/lib64/ld-linux-aarch64.so.1 ./foo
# # To read the current interpreter:
# readelf -a ./foo | ag interpreter
# # To print the dynamic libraries:
# ldd -v ./foo
# # To find libraries that need patching
# ldd ./foo | grep 'not found'
# # To find the interpreter in NixOS
# cat $NIX_CC/nix-support/dynamic-linker
# # To list the required dynamic libraries
# patchelf --print-needed ./foo

NixFormat() {
  if [ -n "$1" ]; then
    alejandra $@
    return
  fi
  alejandra ./**/*.nix
}

if type vegeta >/dev/null 2>&1; then
  VegetaAttack() {
    # Example usage: VegetaAttack -rate=100 -duration=10s -targets=targets.txt
    vegeta attack $@ | tee /tmp/vegeta-results.bin | vegeta report
  }
  alias VegetaDocs='echo https://www.scaleway.com/en/docs/tutorials/load-testing-vegeta/'
fi
