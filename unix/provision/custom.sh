# custom START

if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|--color.light|--color=dark|' ~/.shellrc
  sed -i 's|--color.light|--color=dark|' /tmp/tmux_choose_session.sh
fi

update_vim_colors_theme

git config --global user.name 'Foo Bar'
git config --global user.email foo@bar.com
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

cat >> ~/.bashrc <<"EOF"
if [ ! -f "$HOME"/.check-files/vpn-info ]; then
  echo '[~/.check-files/vpn-info]: Update vpn info in the grep'
fi
_get_if_vpn() {
  IS_VPN=$(ps -aux | grep -E 'onevpn|othervpn' | grep -v grep)
  if [ ! -z "$IS_VPN" ]; then
    echo '[VPN] '
  else
    printf ''
  fi
}
EOF

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
  else
    tmux
  fi
fi
EOF

# custom END

echo "finished provisioning"
