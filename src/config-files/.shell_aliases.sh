PROVISION_CONFIG="$HOME/development/environment/project/.config"

alias ag="rg -S --hidden --colors='path:fg:0xaa,0xaa,0xff'"
alias agg='ag --hidden --ignore node_modules --ignore .git'
alias b='bash'
alias cp="cp -r"
alias dp="docker ps -a"
alias f='fd --type f .'
alias h="sad"
alias htop="htop --no-color"
alias khal='LC_ALL= LC_TIME=en_US.UTF-8 khal'
alias l="less"
alias ll="ls -lahv --color=always"
alias lsblk="lsblk -f"
alias m="mkdir -p"
alias rm="rm -rf"
alias rsr="rsync --remove-source-files -av --progress"
alias s='sd'
alias scp="scp -r"
alias tree="tree -a"
alias up='up -o /tmp/up-result.sh'
alias wget="wget -c"

j() { cat $1 | jq -S "${@:2}" | less; }

alias W='watch --color -n 1 '
alias W2='watch --color -n 2 '
alias W5='watch --color -n 5 '

alias BashClean='env -i bash --norc --noprofile'

# 對於區分大小寫，使用 `-f I`
S() { fd --type f . ${3:-.} | h "$1" "$2" "${@:4}"; }
SK() { fd --type f . ${3:-.} | h "$1" "$2" -k "${@:4}"; }

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

alias ca="~/.local/bin/canto-cli"

alias Lsblk="lsblk -f | less -S"

for i in $(seq 1 20); do
  eval "alias AwkPrint$i=$'awk \'{ print $"$i"; }\''"
done

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

Vidir() { vidir -v -; } # To remove files, remove the lines
VidirFind() { find $@ | sort -V | vidir -v -; }
VisudoUser() { sudo env EDITOR=vim visudo -f /etc/sudoers.d/$1; }
alias ClipboardSSHSend="clipboard_ssh send"
alias HostClipboardSSH="clipboard_ssh host"

alias Vpn='(cd ~/development/environment && bash src/scripts/misc/vpn.sh)'

alias UnameKernel='uname -r'

alias UtilityFor='for i in $(seq 0 5); do echo $i ; done'

FfmpegSubsList() {
  test -n "$1" || { echo "缺少影片路徑" && return 1; }
  nix-shell -p ffmpeg \
    --run "ffprobe -i $1 -show_entries stream=index:stream_tags=language -select_streams s -of compact=p=0:nk=1 -v quiet"
}

FfmpegSubs() {
  test -n "$1" || { echo "缺少影片路徑" && return 1; }
  nix-shell -p ffmpeg --run "ffmpeg -i $1 -map 0:s:${2:-0} ${3:-$1}.srt"
}

FfmpegAudioMp3() {
  test -n "$1" || { echo "缺少影片路徑" && return 1; }
  nix-shell -p ffmpeg --run "ffmpeg -i $1 -q:a 0 -map a $1.mp3"
}

# Cross-platform (including remote VM) function which accepts text from a pipe
ClipboardCopyPipe() {
  read INPUT
  if [ -z "$INPUT" ]; then return; fi
  if ! type clipboard_ssh >/dev/null 2>&1 || [ -z "$(Ports | grep 2030 || true)" ]; then
    if [ -n "$(uname -a | grep Darwin || true)" ]; then
      echo "$INPUT" | pbcopy
    elif type wl-copy >/dev/null 2>&1; then
      echo "$INPUT" | wl-copy
    else
      echo "$INPUT" | xclip -selection clipboard
    fi
  else
    echo "$INPUT" | clipboard_ssh send
  fi
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
SSHForwardPortLocal() {
  echo "Forwarding port: $1 for ${@:2}"
  ssh -N -L "$1":localhost:"$1" ${@:2}
} # SSHForwardPort 1234 192.168.1.40
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
alias EditProvision="(cd ~/development/environment && $EDITOR src/main.sh && cargo run --release)"
alias FDisk='sudo fdisk /dev/sda'
alias FilterLeaf=$'sort -r | awk \'a!~"^"$0{a=$0;print}\' | sort'
alias FlatpackInit='flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo'
alias FormatProto='clang-format -i'
alias GeoInfo='curl -s ipinfo.io | jq .'
alias HierarchyManual='man hier'
alias IPPublic='curl ifconfig.co'
alias IPLocal=$'ifconfig -a | ag "inet\\b" | ag -v " 127" | awk \'{ print $2; }\' | sort'
alias LastColumn="awk '{print "'$NF'"}'"
alias PathShow='echo $PATH | tr ":" "\n" | sort | uniq | less'
alias Provision="(cd ~/development/environment && bash src/main.sh)"
alias ProvisionUpdate="(cd ~/development/environment && IS_PROVISION_UPDATE=1 bash src/main.sh)"
alias PsTree='pstree -s'
alias RsyncDelete='rsync -rhv --delete' # remember to add a slash at the end of source (dest doesn't matter)
alias ShellChangeToBash='chsh -s /bin/bash; exit'
alias SocketSearch='sudo ss -lntup'
alias SyncProvisionCustom='(cd ~/development/environment && bash src/scripts/copy_custom.sh)'
alias TreeDir='tree -d'
alias Visudo='sudo env EDITOR=vim visudo'
alias Xargs='xargs -I{} '
alias YoutubeChooseResolution='yt-dlp -f ' # e.g. YoutubeChooseResolution 12 https://...
alias YoutubeResolutions='yt-dlp -F '
alias YoutubeSubtitles='yt-dlp --all-subs --skip-download'

alias CrontabUser='crontab -e'
alias CrontabRoot='sudo EDITOR=vim crontab -e'

alias Headers='curl -I' # e.g. Headers google.com
if [ -n "$(uname -a | ag Darwin || true)" ]; then
  alias Ports=$"SudoNix netstat -anvp tcp | awk 'NR<3 || /LISTEN/' | awk '{ print \$4 }'"
else
  alias Ports='SudoNix netstat -tulanp'
fi
alias NetstatConnections='netstat -nputw'
alias AnsiColorsRemove="sed 's/\x1b\[[0-9;]*m//g'"

alias TK='tmux kill-server'
KillAllTmux() {
  (
    killall /usr/bin/tmux || true
    killall tmux || true
    killall $(which tmux) || true
  ) >/dev/null 2>&1
  ps aux | grep tmux | grep -v grep | awk '{print $2}' | xargs -I{} kill {}
}
TA() {
  tmux -L "$(basename $PWD)" attach
}

# 這些別名保留 nix shell 環境
TW() { tmux new-window -e "IN_NIX_SHELL=$IN_NIX_SHELL"; }
TP() { tmux split-window -e "IN_NIX_SHELL=$IN_NIX_SHELL"; }

NmapLocal() {
  # https://github.com/nmap/nmap
  THIRD_NUM=${1:-1}
  nix-shell -p nmap --run "sudo --preserve-env=PATH env  nmap -sn '192.168.$THIRD_NUM.0/24'" >/tmp/nmap-result
  sudo chown $USER /tmp/nmap-result
  sed -i "s|Nmap|\nNmap|" /tmp/nmap-result
  less /tmp/nmap-result
}

WorktreeClone() {
  git clone --bare "$1" .bare
  echo "gitdir: ./.bare" >.git
}

n() {
  NOW=$SECONDS
  bash "$HOME"/development/environment/src/scripts/misc/n.sh $@
  AFTER=$SECONDS
  PASSED=$(($AFTER - $NOW))

  if [ $PASSED -lt 2 ] && [ ! -f "$HOME"/development/environment/project/.config/gui-cursor ] &&
    [ ! -f "$HOME"/development/environment/project/.config/gui-vscode ]; then
    builtin fg
  fi
}

ConfigProvisionList() {
  INITIAL_SHA=$(find ~/development/environment/project/.config -type f | sort -V | sha256sum | awk '{print $1}')
  "$HOME"/.local/bin/provision_choose_config $@ || return
  AFTER_SHA=$(find ~/development/environment/project/.config -type f | sort -V | sha256sum | awk '{print $1}')
  # Stop if no changes
  if [ "$INITIAL_SHA" = "$AFTER_SHA" ]; then return; fi

  if type nix >/dev/null 2>&1; then
    RebuildNix && Provision
  else
    Provision
  fi
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

alias HomeManagerInitFlake='nix run home-manager/release-25.05 -- init'
alias HomeManagerDeleteGenerations='home-manager expire-generations "-1 second"'

if type nix >/dev/null 2>&1; then
  alias di='SudoNix dua interactive'

  alias EnvironmentNixShell='nix develop $HOME/development/environment#environment --command zsh'

  alias NixFlakeUpdateInput='nix flake update' # NixFlakeUpdateInput ghostty
  alias NixListChannels='nix-channel --list'
  alias NixListGenerations="nix-env --list-generations"
  alias NixListPackages='nix-env --query "*"'
  alias NixRemovePackage='nix-env -e'
  alias NixReplPkgs="nix repl --expr 'import <nixpkgs>{}'"
  alias NixReplFlake='nix repl --expr "builtins.getFlake \"$PWD\""'
  alias NixDevelopPath='nix develop path:$(pwd)' # 也可以只運行指令: `NixDevelopPath -c cargo build`

  alias NixBuildISO="(cd ~/development/environment && nix build --impure .#nixosConfigurations.iso-installer.config.system.build.isoImage)"

  NixFindPointersToFile() {
    ITEM="$1"
    if [ -z "$(echo $ITEM | grep -F /nix/store || true)" ]; then
      ITEM="/nix/store$ITEM"
    fi
    sudo find -L /home -samefile $ITEM 2>/dev/null
  }

  alias Nix_FileEval='nix-instantiate --eval'
  alias Nix_EnvInstallPackage='nix-env -iA'

  NixUpdateChannel() {
    if type jq >/dev/null 2>&1; then
      UNSTABLE_REV="$(cat ~/development/environment/flake.lock | jq -r '.nodes.unstable.locked.rev')"
      if [ ! -f ~/.check-files/nix-channel ] || [ -z "$(cat ~/.check-files/nix-channel | grep $UNSTABLE_REV || true)" ]; then
        echo "UNSTABLE_REV: $UNSTABLE_REV"
        nix-channel --remove nixpkgs || true
        nix-channel --add "https://github.com/NixOS/nixpkgs/archive/$UNSTABLE_REV.tar.gz" nixpkgs
        nix-channel --update
        nix-channel --list
        echo "$UNSTABLE_REV" >~/.check-files/nix-channel
      fi
    fi
  }

  NixShell() {
    nix-shell -p $@ --command zsh
  }

  NixClearSpaceOnly() {
    nix-collect-garbage -d
  }

  ClearSpace() {
    if [ -n "$(ps aux | ag 'tmux[ ]new-session')" ]; then
      echo "您應該先停止 tmux，這樣就不會開啟 nix shell"
      return
    fi

    if [ -n "$(ps aux | grep 'nvim' | grep -v 'grep')" ]; then
      echo "你應該先停止nvim"
      return
    fi

    echo "你應該先停止docker容器"
    read "?你呼叫這個函數了嗎 'NixGCRootsDelete'?。 按 ctrl-c 停止。 "

    sudo echo ''

    RebuildNix

    sudo rm -rf ~/.cache/composer
    sudo rm -rf ~/.cache/go-build
    sudo rm -rf ~/.cache/yarn
    sudo rm -rf ~/.cargo
    sudo rm -rf ~/.completions
    sudo rm -rf ~/.go-workspace
    sudo rm -rf ~/.gradle
    sudo rm -rf ~/.local/share/nvim
    sudo rm -rf ~/.local/state/nvim
    sudo rm -rf ~/.npm
    sudo rm -rf ~/.rustup
    sudo rm -rf ~/go
    sudo rm -rf ~/nix-dirs

    NixClearSpaceOnly

    if [ -z "$(cd ~/development/environment && git --no-pager diff HEAD -- src/project_templates/web_apps)" ]; then
      (cd ~/development/environment &&
        sudo rm -rf src/project_templates/web_apps &&
        git checkout -- src/project_templates/web_apps)
    fi

    if type docker >/dev/null 2>&1; then
      docker network prune -f || true
      docker system prune -af || true
      docker volume prune -f || true
    fi

    if type podman >/dev/null 2>&1; then
      podman kill $(podman ps -q)
      podman system prune -af || true
    fi

    nvim --headless "+Lazy! sync" +qa

    RebuildNix && Provision

    echo '開發環境清理'
  }

  NixGCRoots() {
    if [ -n "$1" ] && [ -n "$(echo $1 | grep .)" ]; then
      nix-store --gc --print-roots 2>&1 | ag -v removing | ag -v censored | awk '{ print $1; }' |
        ag $1 | xargs -I{} rm -rf {}
    fi

    nix-store --gc --print-roots 2>&1 | ag -v removing | ag -v censored | awk '{ print $1; }'
  }
  alias NixGCRootsDelete="bash ~/development/environment/src/scripts/toolbox/nix_garbage_collector_roots.sh -"

  NixListShellPkgs() {
    echo $PATH | tr ':' '\n' | ag '/nix/store' | sed 's|^[^-]*-||' | sort | sed 's|-[.0-9]*/bin||' | uniq | l
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

  NixEnvironmentUpgrade() {
    if [ -n "$(ps aux | ag 'tmux[ ]new-session')" ]; then
      echo "您應該先停止 tmux，這樣就不會開啟 nix shell"
      return
    fi
    cd ~/development/environment/src/project_templates/web_apps/tooling
    npm upgrade --save --force
    cd ~/development/environment
    RustUpdateProvisionPackages
    nix flake lock --update-input nixpkgs
    nix flake lock --update-input unstable
    nix flake lock --update-input home-manager
    nix flake lock --update-input flake-utils
    nix flake lock --update-input ghostty
    rm -rf ~/.check-files/nix-channel
    NixUpdateChannel
    bash ~/development/environment/src/scripts/toolbox/nix_sync_input.sh ALL

    echo "其他手動更新:"
    grep -r '@upgrade' nix # @TODO: 透過取得最後的 git sha 自動升級它們

    echo "環境升級了，現在可以清理GC、清理空間了"
  }

  # 該空間對於運行其他別名（不僅僅是 Nix 二進位）也很重要
  # https://linuxhandbook.com/run-alias-as-sudo/
  alias SudoNix='sudo --preserve-env=PATH env '

  alias ProvisionNix="(RebuildNix && Provision)"

  # 由於是通用命令而有不同的前綴
  RebuildNix() {
    if [ -f /etc/os-release ] && [ -n "$(cat /etc/os-release | grep nixos || true)" ]; then
      # 它需要 --impure 標誌，因為它導入/etc/nixos/configuration.nix配置
      (cd ~/development/environment &&
        sudo nixos-rebuild switch \
          --option extra-substituters https://install.determinate.systems \
          --option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= \
          --show-trace --flake path:$PWD --impure)
    fi

    if type home-manager >/dev/null 2>&1; then
      NixUpdateChannel
      # 現在需要 --impure 來讀取配置
      home-manager switch --impure --show-trace --flake ~/development/environment/
    fi
  }

  # # To patch a binary interpreter path, for example for 'foo:
  # patchelf --set-interpreter /usr/lib64/ld-linux-aarch64.so.1 ./foo
  # # To read the current interpreter:
  # readelf -a ./foo | grep interpreter
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

  alias Nu='nix-shell -p nushell --command nu'
else
  alias di='dua interactive'
fi

if type vegeta >/dev/null 2>&1; then
  VegetaAttack() {
    # Example usage: VegetaAttack -rate=100 -duration=10s -targets=targets.txt
    vegeta attack $@ | tee /tmp/vegeta-results.bin | vegeta report
  }
  alias VegetaDocs='echo https://www.scaleway.com/en/docs/tutorials/load-testing-vegeta/'
fi

DockerEnvironment() {
  bash ~/development/environment/src/docker_environment/run.sh
}

DockerEnvironmentAlacritty() {
  START_SCRIPT='alacritty -v --config-file '$HOME'/.config/alacritty/alacritty.yml -e bash -c ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && zsh"' \
    bash src/docker_environment/run.sh
}

if type ruby >/dev/null 2>&1; then
  if [ ! -f ~/development/environment/project/.config/ruby_system ]; then
    mkdir -p "$HOME/.local/gems"
    export GEM_HOME="$HOME/.local/gems"
    export GEM_PATH="$GEM_HOME"
    export PATH="$GEM_HOME/bin:$PATH"
  fi
fi

if type kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  alias k=kubectl

  if [ -f ~/.kube-remote/config ]; then
    kr() { KUBECONFIG=$HOME/.kube-remote/config kubectl $@; }
    # 用 kubectl 完成
    source <(kubectl completion zsh | sed 's/\bkubectl\b/kr/g')
  fi
fi

if type helm >/dev/null 2>&1; then
  source <(helm completion zsh)
fi

if type magick >/dev/null 2>&1; then
  ImageConvertWebpPng() { magick "$1" "${1%.*}.png"; }
fi

if type pkg-config >/dev/null 2>&1; then
  PkgConfigPath() {
    PKG_CONFIG_PATH=$(pkg-config --variable pc_path pkg-config)
    echo $PKG_CONFIG_PATH | tr ':' '\n'
  }
  alias PkgConfigList='pkg-config --list-all'
  alias PkgConfigGTKVersion='pkg-config --modversion gtk4'
fi

if type ps_mem >/dev/null 2>&1; then
  alias MemoryPS='sudo --preserve-env=PATH ps_mem | less'
fi

alias UpdateBootstrap='n $BOOTSTRAP_FILE'
alias TmuxNotesPane="tmux split-window -h zsh -c 'cd ~/development/notes && zsh'"

if type pyenv >/dev/null 2>&1; then
  alias PyEnvList='pyenv install --list'
  alias PyEnvVersions='pyenv versions'
fi

NoteBranch() {
  NOTES_TICKET_PREFIX=""
  if [ ! -f $PROVISION_CONFIG/notes_ticket_prefix ]; then
    echo "缺少 $PROVISION_CONFIG/notes_ticket_prefix"
    return
  fi
  NOTES_TICKET_PREFIX=$(cat $PROVISION_CONFIG/notes_ticket_prefix)
  if [ -z "$NOTES_TICKET_PREFIX" ]; then
    echo "缺少 $PROVISION_CONFIG/notes_ticket_prefix"
    return
  fi

  BRANCH_NAME=$(git branch --show-current)

  if [ -z "$(echo $BRANCH_NAME | grep "^$NOTES_TICKET_PREFIX""-[0-9]*" || true)" ]; then
    if [ -z "$(echo $BRANCH_NAME | grep "NO-TICKET_" || true)" ]; then
      echo "分支名稱不符合格式"
      return
    fi
  fi

  FILE_NAME="~/development/notes/tasks/$BRANCH_NAME.md"

  if [ ! -f $FILE_NAME ]; then
    echo '- `$BRANCH_NAME`' >$FILE_NAME
  fi

  tmux split-window -h zsh -c "cd ~/development/notes && zsh -c 'nvim $FILE_NAME'"
}

P12Info() {
  FILE_PATH="$1"
  FILE_PASS="$2"
  if [ -z "$FILE_PATH" ] || [ -z "$FILE_PASS" ]; then
    echo "缺少參數"
    echo "用法: P12Info <file_path> <file_pass>"
    return
  fi
  openssl pkcs12 -legacy -in "$FILE_PATH" -nodes -passin pass:"$FILE_PASS" |
    openssl x509 -noout -subject
}

ShellSource() {
  IS_MAC=$(uname -a | ag Darwin || true)
  if [ -n "$IS_MAC" ]; then
    . ~/.zshrc
    return
  fi

  if [ -n "$(cat /etc/passwd | grep $USER | awk -F: '{print $7}' | grep zsh || true)" ]; then
    . ~/.zshrc
  elif [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
}

if type hyprctl >/dev/null 2>&1; then
  alias HyprlandClients='hyprctl clients' # 呢個指令會列出窗口
fi

if type mogrify >/dev/null 2>&1; then
  alias ImageResize='mogrify -resize' # e.g. ImageResize 50% image1.jpg
  alias ImageRotate='mogrify -rotate' # e.g. ImageRotate 90 image1.jpg
fi

if type aws >/dev/null 2>&1; then
  alias AWSEC2ListInstances="aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceId:InstanceId, State: State.Name, PublicDnsName:PublicDnsName, Volumes:BlockDeviceMappings[*].Ebs.VolumeId}' --output table"
  alias AWSEC2ListLaunchTemplates="aws ec2 describe-launch-templates --output table"
  alias AWSEC2ListVolumes="aws ec2 describe-volumes --output table"
  alias AWSEC2TerminateInstances="aws ec2 terminate-instances --instance-ids"

  AWSEC2CreateWorkstation() {
    if [ -z "$1" ]; then
      echo "缺少 AvailabilityZone"
    fi
    aws ec2 run-instances --launch-template 'LaunchTemplateId=lt-09ba1f53d219fe756,Version=1' --placement "AvailabilityZone=$1"
  }

  AWSEC2AttachVolumeToInstance() {
    aws ec2 attach-volume --volume-id $1 --instance-id $2 --device /dev/sdf
  }

  AWSEC2Prepare() {
    VOLUME_ID="$(aws ec2 describe-volumes --output json | jq -r '.Volumes[] | select(.State == "available") | .VolumeId')"
    INSTANCES="$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceId:InstanceId, State: State.Name, PublicDnsName:PublicDnsName, Volumes:BlockDeviceMappings[*].Ebs.VolumeId}' --output json)"
    INSTANCE_ID=$(echo "$INSTANCES" | jq -r '.[][] | select(.State == "running") | .InstanceId' | head -n 1)
    if [ -n "$VOLUME_ID" ]; then
      VOLUMES=$(echo "$INSTANCES" | jq -r '.[][] | select(.State == "running") | .Volumes[]')
      if [ -n "$INSTANCE_ID" ] && [ -z "$(echo $VOLUMES | grep $VOLUME_ID || true)" ]; then
        echo "將卷 $VOLUME_ID 附加到實例 $INSTANCE_ID"
        aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdf
      fi
    fi
    if [ -n "$INSTANCE_ID" ]; then
      PUBLIC_DNS=$(echo "$INSTANCES" | jq -r '.[][] | select(.State == "running") | .PublicDnsName' | head -n 1)
      if [ -n "$PUBLIC_DNS" ]; then
        echo "連接到實例 $INSTANCE_ID ($PUBLIC_DNS)"
        cat $HOME/.ssh/config | sed "/workstation$/{n;s/ec2.*/$PUBLIC_DNS/;}" | sponge $HOME/.ssh/config
      fi
    fi
    scp $HOME/development/environment/src/os/debian/install_remote_env_aws.sh admin@workstation:
    ssh -qt admin@workstation 'bash install_remote_env_aws.sh'
    scp $HOME/development/environment/src/os/debian/install_remote_env_aws.sh workstation:
    ssh -qt workstation 'bash install_remote_env_aws.sh'
  }

  AWSCredsEncrypt() {
    if [ ! -d $HOME/.aws ]; then
      echo "缺少 $HOME/.aws" && return
    fi

    (cd $HOME && tar -cf - .aws | age -a -p >$HOME/.aws.enc && rm -rf .aws) || return
    echo "加密咗入去 $HOME/.aws.enc"
  }
  AWSCredsDecrypt() {
    if [ ! -f $HOME/.aws.enc ]; then
      echo "缺少 $HOME/.aws.enc" && return
    fi

    (cd $HOME && age -d $HOME/.aws.enc | tar -xvf -) || return
    echo "解密咗入去 $HOME/.aws"
  }
fi

2FAEncrypt() {
  if [ ! -f ~/.2fa ]; then
    echo "缺少 ~/.2fa" && return
  fi
  cat ~/.2fa | age -e -a -p >~/.2fa.age && rm ~/.2fa
}

2FADecrypt() {
  if [ ! -f ~/.2fa.age ]; then
    echo "缺少 ~/.2fa.age" && return
  fi
  cat ~/.2fa.age | age -d >~/.2fa && rm ~/.2fa.age
}

2FAAdd() {
  if [ -z "$1" ]; then
    echo "缺少參數" && echo "用法: 2FAAdd <name>" && return
  fi
  2fa -add $1
}

if type mise >/dev/null 2>&1; then
  alias MiseListAvailableTools='mise plugins list-all'
  alias MiseListAvailableVersions='mise ls-remote' # MiseListAvailableVersions ruby
fi

Encrypt() {
  if [ -n "$(echo "$1" | grep "\.age" || true)" ]; then
    echo "檔案已經係 .age"
    return
  fi
  cat "$1" | age -a -p -e >"$1".age
}

Decrypt() {
  PATH_WITHOUT_AGE="${1%.age}"
  cat "$1" | age -d >"$PATH_WITHOUT_AGE"
}

ta() {
  SOCKET_NAME="${1:-}"
  if [ -z "$SOCKET_NAME" ]; then
    SOCKET_NAME=$(ss -x -l | grep "tmux" | awk '{ print $5; }' | sed "s|/tmp/tmux-$(id -u)/||" | ag -v default | head)
  fi

  if [ -z "$SOCKET_NAME" ]; then
    tmux attach
  else
    tmux -L "$SOCKET_NAME" attach
  fi
}

if [ -d "$HOME"/go/bin ]; then
  export PATH="$HOME/go/bin:$PATH"
fi
