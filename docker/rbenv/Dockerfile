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

ENV PATH="$PATH:/home/ubuntu/.rbenv/bin"
ENV PATH="$PATH:/home/ubuntu/.rbenv/shims"

# The rbenv install step takes several minutes
RUN (curl -sL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash -) \
  && sudo apt-get update \
  && sudo apt-get install -y libssl-dev zlib1g-dev build-essential g++ \
  && echo 'eval "$(rbenv init -)"' >> /home/ubuntu/.bashrc \
  && eval "$(rbenv init -)" \
  && rbenv install --verbose 2.7.0 \
  && rbenv global 2.7.0
