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

cat >> ~/.vimrc <<"EOF"
function! SetupEnvironment()
  let l:path = expand('%:p')
  if l:path =~ '/home/igncp/foo/bar'
    let g:Fast_grep='. --exclude-dir={node_modules,dist,.git,coverage} --exclude="*.log"'
  elseif l:path =~ '/home/igncp/bar/baz'
    let g:Fast_grep='main'
  else
    let g:Fast_grep='src'
  endif
endfunction
autocmd! BufReadPost,BufNewFile * call SetupEnvironment()
EOF

# Inter-VM communication
mkdir -p ~/vms
cat >> ~/.shell_aliases <<"EOF"
IP_OF__VM='1.2.3.4';
_VMSSH() { (cd ~/vms; ssh "$IP_OF__VM"); }
_VMUpload() { rsync --delete -rh -e ssh "${@:3}" "$1" "$IP_OF__VM":"$HOME"/vms/"$2" ; }
_VMDownload() { rsync --delete -rh -e ssh "${@:3}" "$IP_OF__VM:$1" "$HOME"/vms/"$2"; }
EOF

IS_JOB_MODE=0

PS1_JOB=""
if [ "$IS_JOB_MODE" == "1" ]; then
  PS1_JOB="[JOB] "
fi
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
echo 'export PS1="$PS1_BEGINNING'"$PS1_JOB"'\$(_get_if_vpn)$PS1_NEXT""$PS1_MIDDLE""$PS1_END"' >> ~/.bashrc

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
