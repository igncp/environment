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

# gedit is not strictly necessary but brings some unknown dependencies which
# are
RUN apt-get update \
  && apt-get install software-properties-common gedit -y

USER ubuntu
WORKDIR /home/ubuntu

COPY --chown=ubuntu:root android-studio.tar.gz ./

RUN tar -xf android-studio.tar.gz \
  && rm android-studio.tar.gz

ENV ANDROID_HOME=/home/ubuntu/android-sdk
ENV JAVA_HOME=/home/ubuntu/android-studio/jre
ENV PATH="$PATH:/home/ubuntu/android-sdk/platform-tools"
ENV PATH="$PATH:/home/ubuntu/android-sdk/tools/bin"
ENV PATH="$PATH:/home/ubuntu/android-studio/bin"
