FROM ubuntu:20.04

RUN apt-get update && apt-get install -y x11-apps
ARG user=igncp
ARG home=/home/$user

RUN groupadd -g 1000 $user
RUN useradd -d $home -s /bin/bash -m $user -u 1000 -g 1000 \
  && echo $user:ubuntu | chpasswd \
  && adduser $user sudo

WORKDIR $home
USER $user

ENV HOME $home
COPY --chown=igncp:igncp entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
