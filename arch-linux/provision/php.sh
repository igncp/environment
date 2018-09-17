# php START

# * requires
# - be placed after apache provision
# - be placed after mysql provision (if used)

install_pacman_package php
if type mysql > /dev/null 2>&1 ; then
  sudo sed -i 's|;extension=mysqli|extension=mysqli|' /etc/php/php.ini
  sudo sed -i 's|;extension=pdo_mysql|extension=pdo_mysql|' /etc/php/php.ini
fi

# php END

# php-extras START

# php-apache
if [ ! -f ~/.check-files/php-apache ]; then
  echo "installing php"
  sudo pacman -S --noconfirm php-apache
  # https://wiki.archlinux.org/index.php/Apache_HTTP_Server#PHP
  sudo sh -c "echo '<?php phpinfo(); ?>' > /srv/http/php.php"
  sudo systemctl restart httpd.service
  mkdir -p ~/.check-files && touch ~/.check-files/php-apache
fi
sudo grep -qF -- "LoadModule php7_module modules/libphp7.so" /etc/httpd/conf/httpd.conf || \
  echo "LoadModule php7_module modules/libphp7.so" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null
sudo grep -qF -- "AddHandler php7-script .php" /etc/httpd/conf/httpd.conf || \
  echo "AddHandler php7-script .php" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null
sudo grep -qF -- "Include conf/extra/php7_module.conf" /etc/httpd/conf/httpd.conf || \
  echo "Include conf/extra/php7_module.conf" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null

# composer
  if ! type composer > /dev/null 2>&1 ; then
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
  fi

# wp-cli

if ! type wp > /dev/null 2>&1 ; then
  sudo curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  sudo chmod +x /usr/local/bin/wp
fi
if [ ! -f ~/wp-completion ]; then
  curl https://raw.githubusercontent.com/wp-cli/wp-cli/v1.5.1/utils/wp-completion.bash -o ~/wp-completion
fi
echo 'source_if_exists ~/wp-completion' >> ~/.bash_sources

# php-extras END
