# nodenv

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

ENV PATH="$PATH:/home/ubuntu/.nodenv/bin"

RUN git clone https://github.com/nodenv/nodenv.git ~/.nodenv \
  && cd ~/.nodenv \
  && src/configure \
  && make -C src \
  && eval "$(~/.nodenv/bin/nodenv init -)" \
  && git clone https://github.com/nodenv/node-build.git $(~/.nodenv/bin/nodenv root)/plugins/node-build \
  && git clone https://github.com/nodenv/nodenv-update.git "$(nodenv root)"/plugins/nodenv-update \
  && echo 'eval "$(~/.nodenv/bin/nodenv init -)"' >> /home/ubuntu/.bashrc

COPY --chown=ubuntu:root .node-version .
RUN nodenv install
