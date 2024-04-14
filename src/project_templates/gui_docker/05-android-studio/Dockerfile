FROM ubuntu:22.04

RUN dpkg --add-architecture i386

ARG USER=android

RUN apt update

RUN apt install -y \
  build-essential git neovim wget unzip sudo \
  libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
  libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils vim \
  qemu qemu-kvm bridge-utils libnotify4 libglu1 libvirt-daemon-system \
  libqt5widgets5 openjdk-17-jdk xvfb fonts-monofur \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -g 1000 -r $USER
RUN useradd -u 1000 -g 1000 --create-home -r $USER

RUN adduser $USER libvirt
RUN adduser $USER kvm

RUN echo "$USER:$USER" | chpasswd

RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER

RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER
# 使用 Android 模擬器時需要 /dev/kvm 權限
RUN sudo usermod -a -G render igncp

USER $USER
WORKDIR /home/$USER

ARG ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.3.1.20/android-studio-2022.3.1.20-linux.tar.gz
ARG ANDROID_STUDIO_VERSION=2022.3.1.20
RUN wget "$ANDROID_STUDIO_URL" -O android-studio.tar.gz
RUN tar xzvf android-studio.tar.gz
RUN rm android-studio.tar.gz
ENV ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
ENV PATH=$PATH:/home/igncp/android-studio/bin
ENV ANDROID_HOME=/home/igncp/Android/Sdk

# 與 Expo 一起使用
RUN sudo apt update && sudo apt install -y rsync tmux

# 用於調試 Android
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN sudo dpkg -i google-chrome-stable_current_amd64.deb || true
RUN sudo apt -f -y install

# 立即保存命令歷史記錄
RUN echo 'shopt -s histappend' >> ~/.bashrc
RUN echo 'PROMPT_COMMAND="history -a;$PROMPT_COMMAND"' >> ~/.bashrc

ENV PATH=$PATH:/home/igncp/Android/Sdk/platform-tools
