FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y gimp \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["gimp"]
