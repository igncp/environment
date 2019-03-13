# dokuwiki

# @TODO: Merge run commands and update timezone

FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y sudo git gcc make curl unzip vim \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -d /home/ubuntu -ms /bin/bash -g root -G sudo -p ubuntu ubuntu \
  && echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && mkdir /home/ubuntu/app \
  && chown ubuntu /home/ubuntu/app

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt \
  && echo "tzdata tzdata/Zones/Europe select Berlin" >> /tmp/preseed.txt \
  && debconf-set-selections /tmp/preseed.txt

RUN apt-get update \
  && apt-get install -y apache2 php libapache2-mod-php

RUN echo '<?php phpinfo(); ?>' > /var/www/html/info.php \
  && sudo sed -i 's|AllowOverride None|AllowOverride All|' /etc/apache2/apache2.conf \
  && a2enmod rewrite

USER ubuntu
WORKDIR /home/ubuntu

RUN echo 'alias ApacheRestart="sudo service apache2 restart"' >> ~/.bashrc
