#!/usr/bin/env bash

DB_PASSWORD="foo"
DB_USER="bar"
DB_USER_PASSWORD="baz"
if ! type apache2 > /dev/null  ; then
  echo "installing lamp tools"

  # wp-cli has some issues if the ondrej/php repo is used

  sudo apt-get update

  sudo apt-get remove -y php*
  
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_PASSWORD"
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_PASSWORD"

  sudo apt-get install -y mysql-server php5-mysql
  sudo apt-get install -y php5 libapache2-mod-php5 php5-mcrypt
  sudo apt-get install -y apache2

  sudo sed -i "s/index.php //; s/index.html /index.php index.html /" /etc/apache2/mods-enabled/dir.conf
  sudo sh -c "echo '<?php phpinfo(); ?>' > /var/www/html/index.php"

  sudo cp /project/provision/apache2.conf /etc/apache2/

  sudo a2enmod rewrite

  sudo service apache2 restart
fi

# composer
  if ! type composer > /dev/null  ; then
    sudo apt-get install -y php5-cli
    
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
  fi

# wordpress
  if [ ! -f ~/wordpress-installation-finished ]; then
    sudo apt-get install -y php5-curl php5-gd php-mbstring php5-mcrypt php-xml php5-xmlrpc php5-mysqlnd-ms

    mysql -u root -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS wordpress;"
    mysql -u root -p$DB_PASSWORD -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    mysql -u root -p$DB_PASSWORD -e "GRANT ALL ON wordpress.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_USER_PASSWORD';"

    cd ~

    # wp-cli
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp

    curl -O https://wordpress.org/latest.tar.gz
    rm -rf wordpress
    tar xzvf latest.tar.gz
    touch wordpress/.htaccess
    chmod 660 wordpress/.htaccess
    # remember to curl -s https://api.wordpress.org/secret-key/1.1/salt/
    cp /project/provision/wp-config.php wordpress/wp-config.php
    mkdir -p wordpress/wp-content/upgrade
    sudo rm -rf /var/www/html/wordpress
    sudo ln -s /home/vagrant/wordpress /var/www/html/

    sudo chown -R vagrant:www-data /var/www/html
    sudo chown -R vagrant:www-data wordpress

    cd ~/wordpress
    wp core install --title="WP TITLE" --url="http://localhost:9080/wordpress" \
      --admin_user=admin --admin_password=password --admin_email=info@example.com
    cd ~

    sudo service apache2 restart

    touch ~/wordpress-installation-finished
  fi