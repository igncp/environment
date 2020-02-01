# rbenv

FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y sudo git gcc make curl unzip vim \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -d /home/ubuntu -ms /bin/bash -g root -G sudo -p ubuntu ubuntu \
  && echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && mkdir /home/ubuntu/app \
  && chown ubuntu /home/ubuntu/app

USER ubuntu
WORKDIR /home/ubuntu

# The rbenv install step takes several minutes
RUN (curl -sL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash -) \
  && sudo apt-get update \
  && sudo apt-get install -y libssl-dev zlib1g-dev build-essential g++ \
  && export PATH="$PATH:/home/ubuntu/.rbenv/bin" \
  && echo 'export PATH="$PATH:/home/ubuntu/.rbenv/bin"' >> /home/ubuntu/.bashrc \
  && echo 'eval "$(rbenv init -)"' >> /home/ubuntu/.bashrc \
  && rbenv install --verbose 2.7.0 \
  && rbenv global 2.7.0 \
  && eval "$(rbenv init -)"
