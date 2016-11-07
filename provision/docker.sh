# docker START

if ! type docker > /dev/null 2>&1 ; then
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt-get update
  sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
  sudo apt-get install -y docker-engine
  # use docker without sudo
    sudo groupadd docker > /dev/null 2>&1
    sudo gpasswd -a ${USER} docker
    sudo service docker restart
fi

cat >> ~/.bash_aliases <<"EOF"
alias DockerRmAll='docker stop $(docker ps -aq); docker rm $(docker ps -aq)'
EOF

# docker END
