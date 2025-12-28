# https://nixos.wiki/wiki/Locales
if [ -f /usr/lib/locale/locale-archive ]; then
  export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
fi

export LANG=zh_TW.UTF-8
export LC_ALL=zh_TW.UTF-8

# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$HOME/.cache/zsh/.zcompdump-$HOST
CASE_SENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(
  git
  ufw
  rust
  zsh-syntax-highlighting
  zsh-autopair
  zsh-completions
)
source $ZSH/oh-my-zsh.sh

# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
bindkey "\C-u" kill-region

nixShells () {
  echo $'cat ~/development/environment/src/nix/shells/*.nix | grep -Pzo --color=never "$1 = (.|\\\\n)+?  }" | bat -f -l nix -p' \
    > /tmp/nix_shell_preview.sh
  SHELL_NAME="$(grep --no-filename -r 'mkShell.*$' ~/development/environment/src/nix/shells/ | \
    sed 's| =.*||; s|^[ ]*||' | sort | fzf --preview ' bash /tmp/nix_shell_preview.sh {}')"
  SHELL_NAME="$(echo -e "${SHELL_NAME}" | tr -d '[:space:]')"
  if [ -z "$SHELL_NAME" ]; then return ; fi
  # 使用 --impure 能夠讀取環境變量
  text_to_add="nix develop --impure ~/development/environment#$SHELL_NAME -c zsh && exit"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
bookmarksFull () {
  text_to_add="$(__FZFBookmarkedCommands)"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
openEnvironment () {
  text_to_add="$(cat $HISTFILE | cut -d';' -f2- | ag '^n ' | ag environment | sort | uniq | fzf)"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
scriptsFull () {
  text_to_add="$(__FZFScripts)"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
sourceConfig () {
  . ~/.shell_aliases
}
openFzf () {
  FILE=$(fd . --type f | fzf)
  if [ -z "$FILE" ]; then return ; fi
  LBUFFER="n $FILE"
  zle accept-line # enter
}
openTmuxPane () {
  # https://www.reddit.com/r/vim/comments/12eg832/comment/jfcg6p3
  LBUFFER=" tmux capture-pane -Jp -S- | nvim -"
  zle accept-line # enter
}

zle -N nixShells
zle -N bookmarksFull
zle -N openEnvironment
zle -N openFiles
zle -N openFzf
zle -N scriptsFull
zle -N sourceConfig
zle -N openTmuxPane

bindkey "\C-q\C-s" openTmuxPane
bindkey "\C-q\C-w" bookmarksFull
bindkey "\C-q\C-a" nixShells
bindkey "\C-q\C-q" scriptsFull
bindkey "\C-q\C-l" openFzf
bindkey "\C-q\C-m" openEnvironment
bindkey "\C-p" sourceConfig
bindkey "\C-k" edit-command-line

export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/|'

backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '\C-h' backward-kill-dir
forward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle kill-word
    zle delete-char
}
zle -N forward-kill-dir
bindkey '\C-g' forward-kill-dir

SOCKET_NAME="$(echo $TMUX | cut -f1 -d',' | sed -E 's|(/private)?/tmp/tmux-[0-9]*/||' |
  sed -E 's|/run/user/[0-9]*/tmux-[0-9]*/||')"
if [[ "$SOCKET_NAME" == "default" ]] || [ -z "$SOCKET_NAME" ]; then
  tmux -L default set-option status off 2> /dev/null
else
  echo "tmux socket: $SOCKET_NAME"
  # tmux -L "$SOCKET_NAME" set-option status on
fi

setopt PROMPT_SUBST
precmd () {
  jobscount=${(M)#${jobstates%%:*}:#running}r/${(M)#${jobstates%%:*}:#suspended}s
  if [[ $jobscount == s0 ]]; then jobscount=; fi
}

if ! type -f provision_get_ps1 &> /dev/null; then
  source "$HOME"/development/environment/src/scripts/misc/ps1.sh
fi
PS1="\$(provision_get_ps1 \$jobscount)"
RPROMPT="\$(provision_get_ps1_right)"

# cd -[tab] to see options. `dirs -v` to list previous history
setopt AUTO_PUSHD                  # pushes the old directory onto the stack
setopt PUSHD_MINUS                 # exchange the meanings of '+' and '-'
setopt CDABLE_VARS                 # expand the expression (allows 'cd -2/tmp')
autoload -U compinit && compinit   # load + start completion
_comp_options+=(globdots)          # include hidden files in completion
zstyle ':completion:*:directory-stack' list-colors '=(#b) #([0-9]#)*( *)==95=38;5;12'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' special-dirs true # include `./` and `../` in completion

_zsh_cli_fg() {
  LAST_JOB="$(jobs | tail -n 1 | grep -o '[0-9]*' | head -n 1)"
  fg "%$LAST_JOB";
}
zle -N _zsh_cli_fg
bindkey '^X' _zsh_cli_fg

alias HistoryDisable='unset HISTFILE'

if [ -f ~/.check-files/zsh-history ]; then
  HISTFILE=$(cat ~/.check-files/zsh-history)
fi

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
ZSH_HIGHLIGHT_STYLES[comment]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=green,bold'

alias ZshBrowseAllAliases='zsh -ixc : 1>&1 | l'

# Create random socket
export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket-$(mktemp -u XXXXX)

if [ -n "$NODENV_ROOT" ]; then
  if type nodenv &> /dev/null; then
    eval "$(nodenv init -)"
  fi
fi

if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi

# 與 bash 中的 control-w 行為相同
my-backward-delete-word() {
    local WORDCHARS=${WORDCHARS//}
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

# 按下 Tab 鍵時展開別名
zstyle ':completion:*' completer _expand_alias _complete _ignored

if type mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

if type fastfetch &> /dev/null && [ -z "$TMUX" ] && [ -z "$VSCODE_SHELL_INTEGRATION" ]; then
  fastfetch -l none || true
fi

if [ -d $HOME/.nix-profile/bin ]; then
  export PATH="$HOME/.nix-profile/bin:$PATH"
fi
