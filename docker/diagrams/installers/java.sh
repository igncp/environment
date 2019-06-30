#!/usr/bin/env bash

# This will be used by the Dockerfile and doesn't need to be run manually

set -e

mv files/java-jdk.tar.gz .

tar -xf java-jdk.tar.gz
sudo mkdir /usr/lib/jvm
sudo mv ./jdk-* /usr/lib/jvm/

JDK_PATH=$(find /usr/lib/jvm -maxdepth 1 -mindepth 1)

sudo update-alternatives --install "/usr/bin/java" "java" "$JDK_PATH/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "$JDK_PATH/bin/javac" 1

sudo chmod a+x /usr/bin/java
sudo chmod a+x /usr/bin/javac

rm java-jdk.tar.gz
