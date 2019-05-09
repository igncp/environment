# java

FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y sudo git gcc make curl unzip vim \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -d /home/ubuntu -ms /bin/bash -g root -G sudo -p ubuntu ubuntu \
  && echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && mkdir /home/ubuntu/app \
  && chown ubuntu /home/ubuntu/app

RUN apt-get update \
  && apt-get install -qqy x11-apps \
  && rm -rf /home/ubuntu/.Xauthority \
  && sudo -u ubuntu echo 'echo "127.0.0.1 $(hostname)" | sudo tee /etc/hosts >/dev/null' >> /home/ubuntu/.bashrc

RUN apt-get update \
  && apt-get install software-properties-common -y

USER ubuntu
WORKDIR /home/ubuntu

COPY --chown=ubuntu:root install.sh java-jdk.tar.gz ./

RUN sh install.sh
