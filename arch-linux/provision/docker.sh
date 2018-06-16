# docker START

install_pacman_package docker

echo 'export PATH=$PATH:/usr/local/lib/docker/bin' >> ~/.bashrc
echo 'source_if_exists ~/.docker-completion.sh' >> ~/.bash_sources

cat >> ~/.bash_aliases <<"EOF"
alias docker="sudo docker"

alias DockerAttachLastContainer='docker start  `docker ps -q -l`; docker attach `docker ps -q -l`'
alias DockerCleanAll='docker stop $(docker ps -aq); docker rm $(docker ps -aq); docker rmi $(docker images -q)'
alias DockerCleanContainers='docker stop $(docker ps -aq); docker rm $(docker ps -aq)'

DockerBashImage() { docker run -it $1 /bin/bash; }
EOF

# Setup with overlay2 filesystem
  # BTRFS subvolumes are not well supported, and they come by default in Arch
  # They generate stale data in /var/lib/docker/subvolumes
  # They can easily fill the whole available space (sometimes, > 10 Gb in one day)
  # It is better to configure a different filesystem. Follow the instructions:
  # https://gist.github.com/hopeseekr/cd2058e71d01deca5bae9f4e5a555440
  # __NOTE__: This will remove all existing Docker content
  # The summary (in case the gist goes down):
    # docker rm $(docker ps -aq); docker rmi -f $(docker images -q)
    # # Stop dockerd
    # sudo -s # all the next commands will be as root
    # for subvolume in /var/lib/docker/btrfs/subvolumes/*; do btrfs subvolume delete $subvolume; done
    # mkdir -p /media; cd /media
    # fallocate -l 2G docker-volume.img # 2Gb in this examples, in the gist is 10Gb
    # mkfs.ext4 docker-volume.img
    # mount -o loop -t ext4 /media/docker-volume.img /var/lib/docker
    # echo "/media/docker-volume.img /var/lib/docker ext4 defaults 0 0" >> /etc/fstab
  # At this point you can exit sudo and start dockerd. In the gist there are some checks commands to confirm

# docker END
