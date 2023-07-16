use std::path::Path;

use crate::base::{system::System, Context};

use self::unalias::setup_unalias;

mod unalias;

pub fn install_omzsh_plugin(context: &mut Context, repo: &str) {
    let name = repo.split('/').last().unwrap();
    let dir = context
        .system
        .get_home_path(&format!(".oh-my-zsh/custom/plugins/{}", name));

    if !Path::new(&dir).exists() {
        println!("Installing oh-my-zsh plugin: {}", name);
        System::run_bash_command(&format!(
            "git clone --depth=1 https://github.com/{repo}.git {dir}"
        ));
    }

    context.files.appendln(
        &context.system.get_home_path(".zshrc"),
        format!("source {dir}/{name}.plugin.zsh").as_str(),
    )
}

pub fn run_zsh(context: &mut Context) {
    let zsh_file = context.system.get_home_path(".zshrc");
    context.system.install_system_package("zsh", None);

    if !Path::new(&context.system.get_home_path(".oh-my-zsh")).exists() {
        System::run_bash_command(
            r###"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc"
mkdir -p ~/.cache/zsh
"###,
        );
    }

    // These have to be before the main zsh block
    install_omzsh_plugin(context, "zsh-users/zsh-completions");
    install_omzsh_plugin(context, "hlissner/zsh-autopair");
    install_omzsh_plugin(context, "zsh-users/zsh-syntax-highlighting");
    install_omzsh_plugin(context, "MichaelAquilina/zsh-you-should-use");

    context.files.append(
        &zsh_file,
        r###"
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
precmd () {
  jobscount=${(M)#${jobstates%%:*}:#running}r/${(M)#${jobstates%%:*}:#suspended}s
  if [[ $jobscount == s0 ]]; then jobscount=; fi
}
PS1='$(~/.scripts/cargo_target/release/ps1 zsh $jobscount)'
NEXT_TASK='$(__get_next_task)'
RPROMPT="[$NEXT_TASK]"

SHELL=/bin/zsh

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

alias ZshBrowseAllAliases='zsh -ixc : 2>&1 | l'
"###,
    );

    context.home_appendln(
        ".shellrc",
        r#"alias ShellChangeToZsh='sudo chsh -s /bin/zsh igncp; exit'"#,
    );

    if context.system.is_linux() {
        context.files.append(
            &zsh_file,
            r###"
eval "$(dircolors /home/$USER/.dircolors)"
"###,
        );

        if !Path::new(&context.system.get_home_path(".zsh/_git")).exists() {
            std::fs::create_dir_all(context.system.get_home_path(".zsh")).unwrap();
            System::run_bash_command(
                r###"
curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
"###,
            )
        }
    }

    context.files.appendln(&zsh_file, "fpath=(~/.zsh $fpath)");

    setup_unalias(context);
}
