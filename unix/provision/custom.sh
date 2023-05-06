# custom START

if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|--color.light|--color=dark|' ~/.shellrc
  sed -i 's|--color.light|--color=dark|' /tmp/tmux_choose_session.sh
fi

update_vim_colors_theme

# git config --global user.name 'Foo Bar'
# git config --global user.email foo@bar.com
# git config --global gpg.format ssh
# git config --global commit.gpgsign true
# git config --global user.signingkey '...' # Public SSH key
## If using 1Password directly Linux, this is needed
# git config --global gpg.ssh.program /opt/1Password/op-ssh-sign
# mkdir -p "$HOME"/.config/git/git
# git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
# # This file is used for `git log --show-signature`, have to add the public key instead of `...`
# echo "icarbajop@gmail.com ..." > "$HOME"/.config/git/allowed_signers
if [ ! -f "$HOME"/.check-files/git-info ]; then
  echo '[~/.check-files/git-info]: configure git user and email info'
fi

cat >> ~/.shellrc <<"EOF"
EOF

cat >> ~/.shell_aliases <<"EOF"
EOF

cat > /tmp/.vimrc <<"EOF"
function! SetupEnvironment()
  let l:path = expand('%:p')
  if l:path =~ '_HOME_/foo/bar'
    let g:Fast_grep='. --exclude-dir={node_modules,dist,.git,coverage} --exclude="*.log"'
  elseif l:path =~ '_HOME_/bar/baz'
    let g:Fast_grep='main'
  else
    let g:Fast_grep='src'
  endif
endfunction
autocmd! BufReadPost,BufNewFile * call SetupEnvironment()
EOF
sed -i 's|_HOME_|'"$HOME"'|g' /tmp/.vimrc
cat /tmp/.vimrc >> ~/.vimrc ; rm -rf /tmp/.vimrc

cat >> ~/.shellrc <<"EOF"
if [ -z "$TMUX" ]; then
  echo 'check if running in VM and remove condition if yes, either way remove this message'
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo 'ssh, not running tmux'
  elif [ "$(tmux list-clients 2> /dev/null | wc -l | tr '\n' '_')" != "0_" ]; then
    echo 'there is already a tmux client, not attaching to session'
  elif [ -n "$(pgrep tmux)" ]; then
    tmux attach
  elif [ -f "$HOME"/project/scripts/bootstrap/Bootstrap_common.sh ]; then
    sh "$HOME"/project/scripts/bootstrap/Bootstrap_common.sh
  elif [ ! -f $HOME/project/.config/no-auto-tmux ]; then
    tmux
  fi
fi
EOF

if [ -f ~/.vim/coc-settings.json ]; then
  jq -S "." ~/.vim/coc-settings.json | sponge ~/.vim/coc-settings.json
fi

# custom END

echo "finished provisioning"
