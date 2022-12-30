# zsh START

install_system_package zsh

if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc"
fi

install_omzsh_plugin() {
  REPO=$1
  NAME=$(echo $REPO | sed -r "s|.+/(.+)|\1|") # foo/bar => bar
  DIR="$HOME"/.oh-my-zsh/custom/plugins/"$NAME"
  if [ ! -d "$DIR" ]; then
    echo "installing $REPO"
    git clone --depth=1 https://github.com/$REPO.git "$DIR"
  fi
  echo 'source '"$DIR/$NAME.plugin.zsh" >> ~/.zshrc
}

install_omzsh_plugin zsh-users/zsh-completions
install_omzsh_plugin hlissner/zsh-autopair

echo "alias ShellChangeToZsh='chsh -s /bin/zsh; exit'" >> ~/.shellrc

cat >> ~/.zshrc <<"EOF"
# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
export ZSH="$HOME/.oh-my-zsh"
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

bookmarksJustInput () {
  text_to_add="$(__FZFBookmarkedCommands)"
  LBUFFER=${text_to_add}
}
bookmarksFull () {
  text_to_add="$(__FZFBookmarkedCommands)"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}
scriptsJustInput () {
  text_to_add="$(__FZFScripts)"
  LBUFFER=${text_to_add}
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
randomScript () {
  TMP_FILE=$(mktemp)
  mv "$TMP_FILE" "$TMP_FILE.sh" && chmod +x "$TMP_FILE.sh"
  printf '#!/bin/bash\nset e\n\n' > "$TMP_FILE.sh"
  text_to_add="nvim +3 $TMP_FILE.sh && sh $TMP_FILE.sh"
  LBUFFER=${text_to_add}
  zle accept-line # enter
}

zle -N bookmarksJustInput
zle -N bookmarksFull
zle -N scriptsJustInput
zle -N scriptsPrint
zle -N scriptsFull
zle -N randomScript

bindkey "\C-q\C-q" bookmarksJustInput
bindkey "\C-q\C-w" bookmarksFull
bindkey "\C-q\C-a" scriptsJustInput
bindkey "\C-q\C-s" scriptsFull
bindkey "\C-p" scriptsPrint
bindkey "\C-k" edit-command-line
bindkey "\C-q\C-i" randomScript

source $HOME/.shellrc
source $HOME/.shell_sources

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
PS1_BEGINNING="$TMUX_PREFIX_A"
PS1_NEXT="%F{$SSH_PS1_NOTICE_COLOR}$SSH_PS1_NOTICE%F{green}%1d"
PS1_MIDDLE='$(__git_ps1) $(get_jobs_prefix)'
# https://miro.medium.com/max/4800/1*Q4WxN-bh4Exk8ULhwSexGQ.png
PS1_END='%F{39}$(date +"%H:%M")$TMUX_PREFIX_B %F{reset_color}'
NEXT_TASK='$(__get_next_task)'
RPROMPT="[$NEXT_TASK]"

PS1=$'\n'$'\n'"$PS1_BEGINNING$PS1_NEXT$PS1_MIDDLE$PS1_END"
SHELL=/bin/zsh

# cd -[tab] to see options. `dirs -v` to list previous history
setopt AUTO_PUSHD                  # pushes the old directory onto the stack
setopt PUSHD_MINUS                 # exchange the meanings of '+' and '-'
setopt CDABLE_VARS                 # expand the expression (allows 'cd -2/tmp')
autoload -U compinit && compinit   # load + start completion
zstyle ':completion:*:directory-stack' list-colors '=(#b) #([0-9]#)*( *)==95=38;5;12'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

_zsh_cli_fg() {
  LAST_JOB="$(jobs | tail -n 1 | grep -o '[0-9]*' | head -n 1)"
  fg "%$LAST_JOB";
}
zle -N _zsh_cli_fg
bindkey '^X' _zsh_cli_fg

alias HistoryDisable='unset HISTFILE'
alias ProvisionUpdate='node ~/project/provision/updateProvision.js; print -S "# cp /tmp/provision/* ~/project/provision/ ; provision.sh"; print -S "sh /tmp/diff_provision.sh"'

# Expand aliases on tab
zstyle ':completion:*' completer _expand_alias _complete _ignored

if [ -f ~/.check-files/zsh-history ]; then
  HISTFILE=$(cat ~/.check-files/zsh-history)
fi
EOF
if [ "$PROVISION_OS" == "LINUX" ]; then
  echo 'eval "$(dircolors /home/'"$USER"'/.dircolors)"' >> ~/.zshrc
fi

install_omzsh_plugin zsh-users/zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
cat >> ~/.zshrc <<"EOF"
ZSH_HIGHLIGHT_STYLES[comment]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=green,bold'
EOF

if [ ! -f ~/.zsh/_git ] && [ "$PROVISION_OS" == "LINUX" ]; then
  mkdir -p ~/.zsh
  curl -o ~/.zsh/_git \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
fi
echo 'fpath=(~/.zsh $fpath)' >> ~/.zshrc

# zsh END
