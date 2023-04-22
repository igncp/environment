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
  cat > ~/.openvpn/_start_cli_template.sh <<"EOF"
#!/usr/bin/env bash
sudo openvpn \
  --config $HOME/.openvpn/LOCATION.ovpn \
  --script-security 2 \
  --auth-user-pass $HOME/.openvpn/creds.txt \
  --up /etc/openvpn/update-systemd-resolved \
  --down /etc/openvpn/update-systemd-resolved \
  --dhcp-option 'DOMAIN-ROUTE .' \
  --down-pre
EOF
fi

if [ -f ~/project/.config/cli-gh ]; then
  if ! type gh > /dev/null 2>&1 ; then
    cd ~; rm -rf gh_cli; mkdir -p gh_cli; cd gh_cli
    if [ "$PROVISION_OS" == "MAC" ]; then
      install_system_package gh
    else
      if [ -n "$ARM_ARCH" ]; then
        wget https://github.com/cli/cli/releases/download/v2.21.1/gh_2.21.1_linux_arm64.tar.gz
      else
        wget https://github.com/cli/cli/releases/download/v2.21.1/gh_2.21.1_linux_amd64.tar.gz
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
alias GHRepoList="gh repo list" # For example: GHRepoList igncp
alias GHRepoClone="gh repo clone" # For example: GHRepoClone igncp/environment
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
    FILTER='Linux.*86_64'
    if [ -n "$ARM_ARCH" ]; then
      if [ "$PROVISION_OS" == "MAC" ]; then
        FILTER='Darwin.*arm64'
      else
        FILTER='Linux.*arm64'
      fi
    fi
    (cd ~ && \
      curl -s https://api.github.com/repos/boyter/scc/releases/latest \
        | grep browser \
        | grep gz \
        | grep "$FILTER" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | xargs wget
      tar -xf scc*.tar.gz
      rm -rf scc*.tar.gz
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

if [ -z "$ARM_ARCH" ]; then
  install_system_package pandoc # document conversion
fi

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

# https://github.com/sharkdp/bat
install_system_package bat
mkdir -p $HOME/.config/bat/
cat > $HOME/.config/bat/config <<"EOF"
# Force colors to see in less, otherwise use normal `cat`
-f
# The default theme doesn't display the numbers with existing colors
--theme=Nord
--style="numbers,changes,header"
EOF
if [ -f /usr/bin/batcat ] && [ ! -f /usr/bin/bat ]; then
  sudo ln -s /usr/bin/batcat /usr/bin/bat
fi

# In Ubuntu ARM, these packages are installed via snap
if [ -z "$ARM_ARCH" ] || [ -z "$(uname -a | grep 'Ubuntu' || true)" ]; then
  # JSON viewer: https://github.com/antonmedv/fx
  install_system_package fx

  # https://github.com/dalance/procs
  install_system_package procs
  procs --gen-completion-out zsh >> ~/.scripts/procs_completion
  echo 'fpath=(~/.scripts/procs_completion $fpath)' >> ~/.zshrc
fi

install_system_package age # https://github.com/FiloSottile/age

if [ -f ~/project/.config/vercel-cli ]; then
  if ! type vercel > /dev/null 2>&1 ; then npm i -g vercel; fi
fi

# cli-tools END
