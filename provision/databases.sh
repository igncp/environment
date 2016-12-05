# databases START

if ! type mongod > /dev/null 2>&1; then
  sudo pacman -S --noconfirm mongodb
  sudo sed -ir "s|bind_ip = .*$|bind_ip = 0.0.0.0|" /etc/mongodb.conf
  sudo systemctl restart mongodb.service
fi

if ! type redis-server > /dev/null 2>&1 ; then
  cd ~
  wget http://download.redis.io/releases/redis-stable.tar.gz
  tar xzf redis-stable.tar.gz && rm -f redis-stable.tar.gz
  cd redis-stable
  make; sudo make install
  sudo rm -rf /etc/redis /var/lib/redis
  sudo mkdir -p /etc/redis /var/lib/redis
  sudo cp -r src/redis-server src/redis-cli /usr/local/bin
  sudo sh -c 'sed -e "s/^daemonize no$/daemonize yes/" -e "s/^# bind 127.0.0.1$/bind 127.0.0.1/" -e "s/^dir \.\//dir \/var\/lib\/redis\//" -e "s/^loglevel verbose$/loglevel notice/" -e "s/^logfile stdout$/logfile \/var\/log\/redis.log/" redis.conf > /etc/redis/redis.conf'
fi

install_pacman_package mariadb

# databases END
