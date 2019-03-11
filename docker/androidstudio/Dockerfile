FROM ubuntu:18.04

RUN apt-get update && \
  apt-get install -y sudo git gcc make curl unzip && \
  rm -rf /var/lib/apt/lists/* && \
  useradd -d /home/ubuntu -ms /bin/bash -g root -G sudo -p ubuntu ubuntu && \
  echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  mkdir /home/ubuntu/app && \
  chown ubuntu /home/ubuntu/app

RUN apt-get update && \
  apt-get install software-properties-common -y && \
  add-apt-repository ppa:webupd8team/java -y && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections && \
  apt-get install oracle-java8-installer android-sdk -y && \
  cd /home/ubuntu/ && \
  wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
  unzip sdk*.zip && \
  sudo rm sdk*.zip && \
  sudo rm -rf /usr/lib/android-sdk/tools && \
  sudo mv tools /usr/lib/android-sdk && \
  yes | sudo /usr/lib/android-sdk/tools/bin/sdkmanager --licenses && \
  sudo chown -R ubuntu /usr/lib/android-sdk

USER ubuntu

WORKDIR /home/ubuntu/app

ENV ANDROID_HOME=/usr/lib/android-sdk
ENV PATH=$PATH:/usr/lib/android-sdk/tools/bin/
