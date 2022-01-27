# aws START

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

# aws END
