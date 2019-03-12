FROM ubuntu:18.04

# Similar images:
# - tizen-studio

RUN apt-get update && \
  apt-get install -y sudo git gcc make curl unzip vim && \
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
  apt-get install oracle-java8-installer android-sdk -y

USER ubuntu
