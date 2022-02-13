# php START

# * requires
# - be placed after apache provision
# - be placed after mysql provision (if used)

install_system_package php
if type mysql > /dev/null 2>&1 ; then
  sudo sed -i 's|;extension=mysqli|extension=mysqli|' /etc/php/php.ini
  sudo sed -i 's|;extension=pdo_mysql|extension=pdo_mysql|' /etc/php/php.ini
fi

# php END

# php-extras START

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
  echo 'source_if_exists ~/wp-completion' >> ~/.shell_sources

# phpactor
  cd ~
  git clone https://github.com/phpactor/phpactor.git --depth 1 .phpactor ; cd .phpactor
  composer install
  sudo ln -s "$(pwd)/bin/phpactor" /usr/local/bin/phpactor
  cd ~

# php-extras END
