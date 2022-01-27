# cli-tools START

# JIRA
# https://github.com/go-jira/jira/releases
if ! type jira > /dev/null 2>&1 ; then
  cd ~; rm -rf go_jira; mkdir -p go_jira; cd go_jira
  wget https://github.com/go-jira/jira/releases/download/v1.0.27/jira-linux-amd64
  sudo mv jira-linux-amd64 /usr/bin/jira
  sudo chmod +x /usr/bin/jira
  cd ~; rm -rf go_jira
fi

install_system_package openvpn
mkdir -p ~/.openvpn
cat > ~/.openvpn/vpn_setup.sh <<"EOF"
VpnConnect() {
  cat >> /tmp/resolv.conf <<"FOOMSG"
nameserver 8.8.8.8
nameserver 8.8.4.4
FOOMSG
  sudo mv /tmp/resolv.conf /etc
  sudo openvpn --config ~/.openvpn/"$1"
}
EOF
cat >> ~/.shell_aliases <<"EOF"
alias VPNLondon='sh ~/.openvpn/vpn_setup.sh London.ovpn'
EOF

# GH CLI
if ! type gh > /dev/null 2>&1 ; then
  cd ~; rm -rf gh_cli; mkdir -p gh_cli; cd gh_cli
  wget https://github.com/cli/cli/releases/download/v2.0.0/gh_2.0.0_linux_amd64.tar.gz
  tar xvzf *.tar.gz
  rm -rf *.tar.gz
  sudo mv gh_*/bin/gh /usr/bin
  cd ~; rm -rf gh_cli
fi
if [ ! -f ~/.gh-completion-bash ]; then
  gh completion --shell bash > ~/.gh-completion-bash
  gh completion --shell zsh > "$HOME"/.oh-my-zsh/custom/plugins/zsh-completions/_gh
  echo '~/.gh-completion generated'
  gh config set editor vim
fi
echo "source_if_exists $HOME/.gh-completion-bash" >> ~/.bashrc
cat >> ~/.shell_aliases <<"EOF"
alias gh='NO_COLOR=1 gh'
alias GHDeployments="gh api repos/{owner}/{repo}/deployments | jq | ag web_url | sort | uniq | less"
EOF

# https://github.com/jarun/googler/releases
if ! type googler > /dev/null 2>&1 ; then
  sudo curl -o /usr/local/bin/googler \
    https://raw.githubusercontent.com/jarun/googler/v4.3.2/googler
  sudo chmod +x /usr/local/bin/googler
  sudo googler -u
  sudo curl -o /usr/share/bash-completion/completions/googler \
    https://raw.githubusercontent.com/jarun/googler/master/auto-completion/bash/googler-completion.bash
fi
cat >> ~/.shell_aliases <<"EOF"
# using lowercase for autocomplete
alias googler='googler -C -n 4'
alias SO='googler -C -n 4 -w https://stackoverflow.com/'
EOF

# Potential installs:
# - https://github.com/firebase/firebase-tools
# - https://github.com/jarun/googler
# - https://github.com/sferik/t
# - https://support.crowdin.com/cli-tool/
# - https://wp-cli.org/

# cli-tools END
