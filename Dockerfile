FROM debian:bookworm

ARG HOST_UID
ENV HOST_UID=${HOST_UID}

RUN apt-get update \
  && apt-get install -y \
  sudo curl xz-utils procps less openssh-server

RUN rm /etc/localtime \
  && ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime \
  && mkdir -p /var/run/sshd \
  && sed -i 's|#Port 22|Port 2200|' /etc/ssh/sshd_config \
  && ssh-keygen -A

RUN useradd -l -u ${HOST_UID} -ms /bin/bash igncp && \
  echo "igncp ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER igncp

ENV USER=igncp
ENV SHELL=/bin/bash

COPY --chown=igncp . /home/igncp/development/environment

WORKDIR /home/igncp/development/environment

RUN mkdir -p project/.config \
  && echo 'iceberg' > project/.config/vim-theme \
  && echo 'CONTAINER' > project/.config/ssh-notice \
  && bash src/main.sh

RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
  && nvim --headless "+Lazy! sync" +qa \
  && export PATH="$PATH:$HOME/.npm-packages/bin" \
  && bash src/main.sh

# 這是目錄應該作為 docker 磁碟區安裝的位置
WORKDIR /app
