# databases START


if ! type mongod > /dev/null 2>&1; then
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
  echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org
  sudo sed -ir "s|bindIp:.*$|bindIp: 0.0.0.0|" /etc/mongod.conf
  sudo service mongod restart
fi

if ! type redis-server > /dev/null 2>&1 ; then
  sudo apt-get install -y tcl8.5
  cd ~
  wget http://download.redis.io/releases/redis-stable.tar.gz
  tar xzf redis-stable.tar.gz && rm -f redis-stable.tar.gz
  cd redis-stable
  make; sudo make install
  sudo rm -rf /etc/redis /var/lib/redis
  sudo mkdir /etc/redis /var/lib/redis
  sudo cp -r src/redis-server src/redis-cli /usr/local/bin
  sudo sh -c 'sed -e "s/^daemonize no$/daemonize yes/" -e "s/^# bind 127.0.0.1$/bind 127.0.0.1/" -e "s/^dir \.\//dir \/var\/lib\/redis\//" -e "s/^loglevel verbose$/loglevel notice/" -e "s/^logfile stdout$/logfile \/var\/log\/redis.log/" redis.conf > /etc/redis/redis.conf'
  wget -q https://raw.github.com/saxenap/install-redis-amazon-linux-centos/master/redis-server
  sudo mv redis-server /etc/init.d
  sudo chmod 755 /etc/init.d/redis-server
fi

MYSQL_DB_PASSWORD="foo"
if ! type mysql > /dev/null 2>&1; then
  echo "mysql-server mysql-server/root_password password $MYSQL_DB_PASSWORD" | sudo debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password $MYSQL_DB_PASSWORD" | sudo debconf-set-selections

  sudo apt-get install -y mysql-server
fi

# databases END
