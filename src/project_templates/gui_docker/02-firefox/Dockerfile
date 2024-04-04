FROM ubuntu:20.04
RUN apt-get update && apt-get install -y firefox
RUN useradd -m igncp -u 1000
USER igncp

CMD "firefox"
