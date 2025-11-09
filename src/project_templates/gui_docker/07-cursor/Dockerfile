FROM ubuntu:24.04

RUN apt update
RUN apt install -y wget gedit
WORKDIR /root
RUN wget https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/1.7
RUN mv 1.7 1.7.deb && apt install -y ./1.7.deb
USER ubuntu
