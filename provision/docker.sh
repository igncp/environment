# docker START

if ! type docker > /dev/null 2>&1 ; then
  mkdir -p ~/docker && cd ~/docker
  download_cached https://www.archlinux.org/packages/community/x86_64/docker/download/ docker.tar.xz ~/docker
  tar -xJf docker.tar.xz
  sudo rm -rf /usr/local/lib/docker; sudo mv usr /usr/local/lib/docker
  cd ~; rm -rf ~/docker
  git clone https://github.com/docker/cli --depth 1 docker-cli
  cp ~/docker-cli/contrib/completion/bash/docker ~/.docker-completion.sh
  rm -rf ~/docker-cli
fi
echo 'export PATH=$PATH:/usr/local/lib/docker/bin' >> ~/.bashrc
echo 'source_if_exists ~/.docker-completion.sh' >> ~/.bash_sources
echo 'alias docker="sudo docker"' >> ~/.bash_aliases

# docker END
