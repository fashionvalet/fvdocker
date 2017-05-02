#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the docker-laravel image
# ------------------------------------------------------------------------------

apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# ------------------------------------------------------------------------------
# NGINX web server and ssh server
# ------------------------------------------------------------------------------

apt-get -y --no-install-recommends install nginx openssh-server
cp /provision/service/nginx.conf /etc/supervisord/nginx.conf


#configuration files
cp /provision/conf/nginx/development /etc/nginx/sites-available/default
# cp /provision/conf/nginx/production.template /etc/nginx/sites-available/production.template

# ------------------------------------------------------------------------------
# PHP7
# ------------------------------------------------------------------------------

# install PHP
apt-get -y --no-install-recommends install php-fpm php-cli
cp /provision/service/php-fpm.conf /etc/supervisord/php-fpm.conf
mkdir -p /var/run/php

apt-get -y --no-install-recommends install php-mbstring php-xml php-mysqlnd php-curl

# disable 'daemonize' in php-fpm (because we use supervisor instead)
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf

# ------------------------------------------------------------------------------
# XDebug (installed but not enabled)
# ------------------------------------------------------------------------------

apt-get -y --no-install-recommends install php-xdebug
phpdismod xdebug
phpdismod -s cli xdebug

# ------------------------------------------------------------------------------
# Composer PHP dependency manager
# ------------------------------------------------------------------------------

curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm ./composer-setup.php

# ------------------------------------------------------------------------------
# MariaDB server
# ------------------------------------------------------------------------------

# install MariaDB client and server
apt-get -y --no-install-recommends install mariadb-client
apt-get -y --no-install-recommends install mariadb-server pwgen
cp /provision/service/mariadb.conf /etc/supervisord/mariadb.conf

# MariaDB seems to have problems starting if these permissions are not set:
mkdir /var/run/mysqld
chmod 777 /var/run/mysqld

# ------------------------------------------------------------------------------
# Node and npm
# ------------------------------------------------------------------------------

curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
chmod +x nodesource_setup.sh
./nodesource_setup.sh
apt-get -y --no-install-recommends install nodejs
apt-get -y --no-install-recommends install build-essential
rm ./nodesource_setup.sh

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------
rm -rf /provision
