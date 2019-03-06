FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y gimp\
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["gimp"]
