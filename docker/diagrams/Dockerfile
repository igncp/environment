# diagrams

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

COPY --chown=ubuntu:root files/java-jdk.tar.gz files/java-jdk.tar.gz
COPY --chown=ubuntu:root installers/java.sh installers/java.sh
RUN sh installers/java.sh

COPY --chown=ubuntu:root installers/graphviz.sh installers/graphviz.sh
RUN sh installers/graphviz.sh

COPY --chown=ubuntu:root files/plantuml.jar files/plantuml.jar

COPY --chown=ubuntu:root files/entr.tar.gz files/entr.tar.gz
COPY --chown=ubuntu:root installers/entr.sh installers/entr.sh
RUN sh installers/entr.sh

ENV PATH="$PATH:/home/ubuntu/.nodenv/bin"
ENV PATH="$PATH:/home/ubuntu/.nodenv/shims"
COPY --chown=ubuntu:root .node-version .
COPY --chown=ubuntu:root installers/node.sh installers/node.sh
RUN sh installers/node.sh

COPY --chown=ubuntu:root installers/mermaid.sh installers/mermaid.sh
RUN sh installers/mermaid.sh
