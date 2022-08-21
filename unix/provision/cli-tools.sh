# cli-tools START

if [ -f ~/project/.config/cli-go-jira ]; then
  # https://github.com/go-jira/jira/releases
  if ! type jira > /dev/null 2>&1 ; then
    cd ~; rm -rf go_jira; mkdir -p go_jira; cd go_jira
    wget https://github.com/go-jira/jira/releases/download/v1.0.27/jira-linux-amd64
    sudo mv jira-linux-amd64 /usr/bin/jira
    sudo chmod +x /usr/bin/jira
    cd ~; rm -rf go_jira
  fi
fi

if [ -f ~/project/.config/cli-openvpn ]; then
  install_system_package openvpn
  mkdir -p ~/.openvpn
  cat > ~/.openvpn/vpn_setup.sh <<"EOF"
    cat >> /tmp/resolv.conf <<"FOOMSG"
nameserver 8.8.8.8
nameserver 8.8.4.4
FOOMSG
sudo mv /tmp/resolv.conf /etc
sudo openvpn --config ~/.openvpn/"$1" ${@:2}
EOF
  cat >> ~/.shell_aliases <<"EOF"
alias VPNLondon='sh ~/.openvpn/vpn_setup.sh London.ovpn'
EOF
fi

if [ -f ~/project/.config/cli-gh ]; then
  if ! type gh > /dev/null 2>&1 ; then
    cd ~; rm -rf gh_cli; mkdir -p gh_cli; cd gh_cli
    if [ "$PROVISION_OS" == "MAC" ]; then
      install_system_package gh
    else
      if [ -n "$ARM_ARCH" ]; then
        wget https://github.com/cli/cli/releases/download/v2.5.1/gh_2.5.1_linux_armv6.tar.gz
      else
        wget https://github.com/cli/cli/releases/download/v2.5.1/gh_2.5.1_linux_amd64.tar.gz
      fi
      tar xvzf *.tar.gz
      rm -rf *.tar.gz
      sudo mv gh_*/bin/gh /usr/local/bin
      cd ~; rm -rf gh_cli
    fi
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
alias GHAuthLogin="gh auth login"
EOF
fi

if [ -f  ~/project/.config/cli-googler ]; then
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
fi

if [ -f ~/project/.config/cli-aws ]; then
  # https://docs.aws.amazon.com/cli/latest/reference/
  if ! type aws > /dev/null 2>&1 ; then
    mkdir -p /tmp/misc
    cd /tmp/misc
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
  fi
  echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc
  cat >> ~/.zshrc <<"EOF"
if ! type complete > /dev/null 2>&1 ; then
  autoload bashcompinit && bashcompinit
fi
complete -C '/usr/local/bin/aws_completer' aws
EOF
fi

if [ -f ~/project/.config/cli-scc ]; then
  if ! type scc > /dev/null 2>&1 ; then
    (cd ~ && \
      curl -s https://api.github.com/repos/boyter/scc/releases/latest \
        | grep unknown-linux \
        | grep browser \
        | grep 86_64 \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | xargs wget
      unzip scc*64*.zip
      rm scc*.zip
      sudo mv scc /usr/bin)
  fi
fi

# hhighlighter: `h` command
if [ ! -f ~/hhighlighter/h.sh ] > /dev/null 2>&1 ; then
  rm -rf ~/hhighlighter
  git clone --depth 1 https://github.com/paoloantinori/hhighlighter.git ~/hhighlighter
fi
echo 'source_if_exists ~/hhighlighter/h.sh' >> ~/.shell_sources
install_system_package ack # Required by hhighlighter

install_system_package pandoc # document conversion
install_system_package graphviz dot

# Potential installs:
# - https://github.com/firebase/firebase-tools
# - https://support.crowdin.com/cli-tool/

# `doctl`
  # Download the latest release from: https://github.com/digitalocean/doctl/releases/
  # The `doctl completion zsh` and the ohmyzsh plugin didn't work during tests
  if type doctl > /dev/null 2>&1 ; then
    cat >> ~/.shell_aliases <<"EOF"
# Keep the token encrypted and don't keep the user logged in
alias DOLogin='doctl auth init'
alias DOLogout='doctl auth remove --context default'
alias DODroplets='doctl compute droplet list'
EOF
  fi

# cli-tools END
