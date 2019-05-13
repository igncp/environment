# android-studio

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

USER ubuntu
WORKDIR /home/ubuntu

COPY --chown=ubuntu:root flutter-sdk.tar.xz .

ENV PATH="$PATH:/home/ubuntu/flutter/bin"

RUN sudo apt-get update \
  && sudo apt-get install -y lib32stdc++6 \
  && tar xf flutter-sdk.tar.xz \
  && rm -rf flutter-sdk.tar.xz \
  && flutter precache \
  && flutter config --no-analytics

# Install Android Studio: Refer to `android-studio` docker image
