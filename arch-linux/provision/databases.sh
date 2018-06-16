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

install_pacman_package mariadb mysql
install_pacman_package mysql-workbench

install_pacman_package postgresql postgres
if [ ! -f ~/.check-files/postgresql ]; then
  sudo mkdir -p /var/lib/postgres/data
  sudo chown -c -R postgres:postgres /var/lib/postgres
  sudo systemctl enable postgresql
  sudo -H -u postgres bash -c "initdb -D '/var/lib/postgres/data'"
  sudo -u postgres createuser igncp
  sudo -u postgres createdb igncp
  sudo -u postgres psql -c 'ALTER USER igncp WITH SUPERUSER;'
  sudo systemctl restart postgresql
  mkdir -p ~/.check-files && touch ~/.check-files/postgresql
fi
cat >> ~/.bash_aliases <<"EOF"
alias PostgresSQLRestart='sudo systemctl restart postgresql.service'
alias PostgresSQLStatus='sudo systemctl status postgresql.service'
EOF

if [ ! -f ~/.check-files/pgadmin ]; then
  PGADMIN_FILE=pgadmin4-1.1-py3-none-any.whl
  download_cached https://ftp.postgresql.org/pub/pgadmin3/pgadmin4/v1.1/pip/$PGADMIN_FILE $PGADMIN_FILE ~
  sudo pip install ~/$PGADMIN_FILE
  rm ~/$PGADMIN_FILE
  sudo chown -R igncp /usr/lib/python3.5/site-packages/pgadmin4/
  sudo mkdir -p /var/log/pgadmin4
  sudo chown -R igncp /var/log/pgadmin4
  mkdir -p ~/.check-files && touch ~/.check-files/pgadmin
fi
cat > /usr/lib/python3.5/site-packages/pgadmin4/config_local.py <<"EOF"
SERVER_MODE = True
LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'
SQLITE_PATH = '/usr/lib/python3.5/site-packages/pgadmin4/pgadmin4.db'
SESSION_DB_PATH = '/usr/lib/python3.5/site-packages/pgadmin4/sessions'
STORAGE_DIR = '/usr/lib/python3.5/site-packages/pgadmin4/storage'
DEFAULT_SERVER='0.0.0.0'
EOF
cat >> ~/.bash_aliases <<"EOF"
alias PGAdminStart='python /usr/lib/python3.5/site-packages/pgadmin4/pgAdmin4.py'
EOF

# databases END
