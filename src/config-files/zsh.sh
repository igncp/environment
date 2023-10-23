export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$HOME/.cache/zsh/.zcompdump-$HOST
CASE_SENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(
  git
  ufw
  zsh-syntax-highlighting
  zsh-autopair
  zsh-completions
)
source $ZSH/oh-my-zsh.sh

# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
bindkey "\C-g" vi-forward-blank-word
bindkey "\C-f" vi-backward-blank-word
bindkey "\C-u" kill-region

bashCalls () {
  text_to_add="$(cat $HISTFILE | cut -d';' -f2- | ag '^b ' | sort | uniq | fzf)"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
bookmarksFull () {
  text_to_add="$(__FZFBookmarkedCommands)"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
openFiles () {
  text_to_add="$(cat $HISTFILE | cut -d';' -f2- | ag '^n ' | sort | uniq | fzf)"
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
scriptsPrint () {
  text_to_add="$(__FZFScriptsRaw)"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
openFzf () {
  FILE=$(fd . --type f | fzf)
  if [ -z "$FILE" ]; then return ; fi
  LBUFFER="n $FILE"
  zle accept-line # enter
}

zle -N bashCalls
zle -N bookmarksFull
zle -N openEnvironment
zle -N openFiles
zle -N openFzf
zle -N scriptsFull
zle -N scriptsPrint

bindkey "\C-q\C-q" bashCalls
bindkey "\C-q\C-w" bookmarksFull
bindkey "\C-q\C-a" openFiles
bindkey "\C-q\C-s" scriptsFull
bindkey "\C-q\C-l" openFzf
bindkey "\C-q\C-m" openEnvironment
bindkey "\C-p" scriptsPrint
bindkey "\C-k" edit-command-line

export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/|'

backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '\C-h' backward-kill-dir

SOCKET_NAME="$(echo $TMUX | cut -f1 -d',' | sed -E 's|(/private)?/tmp/tmux-[0-9]*/||')"
if [[ "$SOCKET_NAME" == "default" ]] || [ -z "$SOCKET_NAME" ]; then
  tmux -L default set-option status off
else
  echo "tmux socket: $SOCKET_NAME"
  tmux -L "$SOCKET_NAME" set-option status on
fi

__get_next_task() {
  ID=$(task next limit:1 2>&1 | grep -v 'No matches.' | tail -n +4 | head -n 1 | sed "s/^ //" | cut -d " " -f1 | grep .)
  if [ -z "$ID" ]; then
    printf "-"
  else
    task _get "$ID".description
  fi
}

setopt PROMPT_SUBST
precmd () {
  jobscount=${(M)#${jobstates%%:*}:#running}r/${(M)#${jobstates%%:*}:#suspended}s
  if [[ $jobscount == s0 ]]; then jobscount=; fi
}
PS1='$(~/.scripts/cargo_target/release/ps1 zsh $jobscount)'
NEXT_TASK='$(__get_next_task)'
RPROMPT="[$NEXT_TASK]"

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

# Expand aliases on tab
# zstyle ':completion:*' completer _expand_alias _complete _ignored

if [ -f ~/.check-files/zsh-history ]; then
  HISTFILE=$(cat ~/.check-files/zsh-history)
fi

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
ZSH_HIGHLIGHT_STYLES[comment]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=green,bold'

alias ZshBrowseAllAliases='zsh -ixc : 1>&1 | l'

# Create random socket
export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket-$(mktemp -u XXXXX)
