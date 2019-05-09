#!/usr/bin/env bash

# Instructions: Need to download Java JDK and place it in this directory

# - The Java JDK needs to have the name: `java-jdk.tar.gz`
# https://www.java.com/en/download/manual.jsp
# https://www.oracle.com/technetwork/java/javase/downloads/index-jsp-138363.html#javasejdk

set -e

sudo docker build \
  -t java \
  .
