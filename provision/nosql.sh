# nosql START

if ! type mongod > /dev/null 2>&1; then
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
  echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org
  sudo sed -ir "s|bindIp:.*$|bindIp: 0.0.0.0|" /etc/mongod.conf
  sudo service mongod restart
fi

# nosql END
