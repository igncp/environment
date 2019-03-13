#!/usr/bin/env bash

# Download the *.tgz file from:
# https://download.dokuwiki.org/
# And copy it into /home/ubuntu from /project

set -e

cd /home/ubuntu

rm -rf dokuviki

tar -xvzf doku*.tgz

sudo rm -rf /var/www/html
sudo mkdir /var/www/html
sudo cp -r dokuwiki/* /var/www/html
sudo cp -r dokuwiki/.htaccess.dist /var/www/html/.htaccess

sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 700 /var/www/html

sudo service apache2 restart

echo ""
echo "Go to http://URL:PORT/install.php"
