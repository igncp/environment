#!/usr/bin/env bash

# java
  if ! type java > /dev/null  ; then
    sudo add-apt-repository -y ppa:webupd8team/java
    sudo apt-get update
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
    sudo apt-get install -y oracle-java8-installer
  fi

  if ! type gradle > /dev/null  ; then
    wget https://services.gradle.org/distributions/gradle-3.1-bin.zip
    unzip gradle-3.1-bin.zip
    rm gradle-3.1-bin.zip
    sudo mv gradle-3.1 /usr/local/lib/gradle
    curl -L -s https://gist.github.com/nolanlawson/8694399/raw/gradle-tab-completion.bash \
      -o ~/gradle-tab-completion.bash
  fi
