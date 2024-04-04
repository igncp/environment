FROM ubuntu:22.04

RUN apt update
RUN apt install -y wget gnupg
RUN wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
  | gpg --dearmor | tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
RUN echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
RUN apt update
RUN apt install -y sublime-text

RUN useradd -m igncp -u 1000

RUN apt install -y libgl1 locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
  locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER igncp
WORKDIR /home/igncp

CMD ["bash", "-c", "subl"]
