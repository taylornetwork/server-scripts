#!/usr/bin/env bash

if (( $EUID == 0 ))
then
	echo 'Do not run as root'
	exit 1
fi

# *** Run using `bash Provision.sh` DO NOT RUN USING SUDO ***

# These are the default settings...
# username = ubuntu
# mysql_password = secret
# timezone = UTC

# Change before running by using `sed -i 's/ubuntu/someusername/g' Provision.sh` for example.

export DEBIAN_FRONTEND=noninteractive

sudo -E tee /etc/apt/apt.conf.d/local << EOF
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
}
EOF

# Update Package List
sudo -E apt-get update

# Update System Packages
sudo -E apt-get upgrade -y

# Force Locale
sudo -E echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
sudo -E locale-gen en_US.UTF-8

sudo -E apt-get install -y software-properties-common curl

# Install Some PPAs
sudo -E apt-add-repository ppa:ondrej/php -y
# NodeJS
sudo -E curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

## Update Package Lists
sudo -E apt-get update

# Install Some Basic Packages
sudo -E apt-get install -y build-essential dos2unix gcc git git-lfs libmcrypt4 libpcre3-dev libpng-dev chrony unzip make \
python3-pip re2c supervisor unattended-upgrades whois vim libnotify-bin pv cifs-utils mcrypt bash-completion zsh \
graphviz avahi-daemon tshark imagemagick

# Set My Timezone
sudo -E ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install Generic PHP packages
sudo -E apt-get install -y --allow-change-held-packages \
php-imagick php-memcached php-redis php-xdebug php-dev

# PHP 8.0
sudo -E apt-get install -y --allow-change-held-packages \
php8.0 php8.0-bcmath php8.0-bz2 php8.0-cgi php8.0-cli php8.0-common php8.0-curl php8.0-dba php8.0-dev \
php8.0-enchant php8.0-fpm php8.0-gd php8.0-gmp php8.0-imap php8.0-interbase php8.0-intl php8.0-ldap \
php8.0-mbstring php8.0-mysql php8.0-odbc php8.0-opcache php8.0-pgsql php8.0-phpdbg php8.0-pspell php8.0-readline \
php8.0-snmp php8.0-soap php8.0-sqlite3 php8.0-sybase php8.0-tidy php8.0-xml php8.0-xsl php8.0-zip

# PHP 7.4
sudo -E apt-get install -y --allow-change-held-packages \
php7.4 php7.4-bcmath php7.4-bz2 php7.4-cgi php7.4-cli php7.4-common php7.4-curl php7.4-dba php7.4-dev \
php7.4-enchant php7.4-fpm php7.4-gd php7.4-gmp php7.4-imap php7.4-interbase php7.4-intl php7.4-json php7.4-ldap \
php7.4-mbstring php7.4-mysql php7.4-odbc php7.4-opcache php7.4-pgsql php7.4-phpdbg php7.4-pspell php7.4-readline \
php7.4-snmp php7.4-soap php7.4-sqlite3 php7.4-sybase php7.4-tidy php7.4-xml php7.4-xmlrpc php7.4-xsl php7.4-zip

sudo -E update-alternatives --set php /usr/bin/php8.0
sudo -E update-alternatives --set php-config /usr/bin/php-config8.0
sudo -E update-alternatives --set phpize /usr/bin/phpize8.0

# Install Composer
sudo -E curl -sS https://getcomposer.org/installer | php
sudo -E mv composer.phar /usr/local/bin/composer
sudo -E chown -R ubuntu:ubuntu /home/ubuntu/.config

# Install Global Packages
/usr/local/bin/composer global require "laravel/envoy=^2.0"
/usr/local/bin/composer global require "laravel/installer=^4.0.2"
/usr/local/bin/composer global require "laravel/spark-installer=dev-master"
/usr/local/bin/composer global require "slince/composer-registry-manager=^2.0"


# Set Some PHP CLI Settings
sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/cli/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/cli/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/cli/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/cli/php.ini

sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini


# Install Nginx
sudo -E apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages nginx

sudo -E rm /etc/nginx/sites-enabled/default
sudo -E rm /etc/nginx/sites-available/default

# Create a configuration file for Nginx overrides.
sudo -E mkdir -p /home/ubuntu/.config/nginx
sudo -E chown -R ubuntu:ubuntu /home/ubuntu
sudo -E touch /home/ubuntu/.config/nginx/nginx.conf
sudo -E ln -sf /home/ubuntu/.config/nginx/nginx.conf /etc/nginx/conf.d/nginx.conf

# Setup Some PHP-FPM Options
sudo -E echo "xdebug.mode = debug" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "xdebug.discover_client_host = true" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "xdebug.client_port = 9003" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "xdebug.max_nesting_level = 512" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "opcache.revalidate_freq = 0" >> /etc/php/8.0/mods-available/opcache.ini

sudo -E echo "xdebug.mode = debug" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "xdebug.discover_client_host = true" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "xdebug.client_port = 9003" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "xdebug.max_nesting_level = 512" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "opcache.revalidate_freq = 0" >> /etc/php/7.4/mods-available/opcache.ini

sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/fpm/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/fpm/php.ini
sudo -E sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.0/fpm/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/fpm/php.ini
sudo -E sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.0/fpm/php.ini
sudo -E sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.0/fpm/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/fpm/php.ini

sudo -E printf "[openssl]\n" | tee -a /etc/php/8.0/fpm/php.ini
sudo -E printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.0/fpm/php.ini

sudo -E printf "[curl]\n" | tee -a /etc/php/8.0/fpm/php.ini
sudo -E printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.0/fpm/php.ini

sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/fpm/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/fpm/php.ini
sudo -E sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
sudo -E sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
sudo -E sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.4/fpm/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini

sudo -E printf "[openssl]\n" | tee -a /etc/php/7.4/fpm/php.ini
sudo -E printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini

sudo -E printf "[curl]\n" | tee -a /etc/php/7.4/fpm/php.ini
sudo -E printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini

# Disable XDebug On The CLI
sudo -E phpdismod -s cli xdebug

# Set The Nginx & PHP-FPM User
sudo -E sed -i "s/user www-data;/user ubuntu;/" /etc/nginx/nginx.conf
sudo -E sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sudo -E sed -i "s/user = www-data/user = ubuntu/" /etc/php/8.0/fpm/pool.d/www.conf
sudo -E sed -i "s/group = www-data/group = ubuntu/" /etc/php/8.0/fpm/pool.d/www.conf

sudo -E sed -i "s/listen\.owner.*/listen.owner = ubuntu/" /etc/php/8.0/fpm/pool.d/www.conf
sudo -E sed -i "s/listen\.group.*/listen.group = ubuntu/" /etc/php/8.0/fpm/pool.d/www.conf
sudo -E sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.0/fpm/pool.d/www.conf

sudo -E sed -i "s/user = www-data/user = ubuntu/" /etc/php/7.4/fpm/pool.d/www.conf
sudo -E sed -i "s/group = www-data/group = ubuntu/" /etc/php/7.4/fpm/pool.d/www.conf

sudo -E sed -i "s/listen\.owner.*/listen.owner = ubuntu/" /etc/php/7.4/fpm/pool.d/www.conf
sudo -E sed -i "s/listen\.group.*/listen.group = ubuntu/" /etc/php/7.4/fpm/pool.d/www.conf
sudo -E sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.4/fpm/pool.d/www.conf

sudo -E service nginx restart
sudo -E service php8.0-fpm restart
sudo -E service php7.4-fpm restart

# Add ubuntu User To WWW-Data
sudo -E usermod -a -G www-data ubuntu
sudo -E id ubuntu
sudo -E groups ubuntu

# Install Node
sudo -E apt-get install -y nodejs
/usr/bin/npm install -g npm
/usr/bin/npm install -g gulp-cli
/usr/bin/npm install -g bower
/usr/bin/npm install -g yarn
/usr/bin/npm install -g grunt-cli


# Install SQLite
sudo -E apt-get install -y sqlite3 libsqlite3-dev

# Install MySQL
sudo -E echo "mysql-server mysql-server/root_password password secret" | debconf-set-selections
sudo -E echo "mysql-server mysql-server/root_password_again password secret" | debconf-set-selections
sudo -E apt-get install -y mysql-server

# Configure MySQL 8 Remote Access and Native Pluggable Authentication
sudo -E cat > /etc/mysql/conf.d/mysqld.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
default_authentication_plugin = mysql_native_password
EOF

# Configure MySQL Password Lifetime
sudo -E echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Configure MySQL Remote Access
sudo -E sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo -E service mysql restart

export MYSQL_PWD=secret

mysql --user="root" -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'secret';"
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
mysql --user="root" -e "FLUSH PRIVILEGES;"

sudo -E tee /home/ubuntu/.my.cnf <<EOL
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_bin
EOL

# Add Timezone Support To MySQL
sudo -E mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=secret mysql
sudo -E service mysql restart

# Configure Supervisor
sudo -E systemctl enable supervisor.service
sudo -E service supervisor start

# One last upgrade check
sudo -E apt-get upgrade -y

# Clean Up
sudo -E apt -y autoremove
sudo -E apt -y clean
sudo -E chown -R ubuntu:ubuntu /home/ubuntu
sudo -E chown -R ubuntu:ubuntu /usr/local/bin

# Add Composer Global Bin To Path
printf "\nPATH=\"$(sudo su - ubuntu -c 'composer config -g home 2>/dev/null')/vendor/bin:\$PATH\"\n" | tee -a /home/ubuntu/.profile

# Delete oddities
sudo -E apt-get -y purge popularity-contest installation-report command-not-found friendly-recovery laptop-detect

# Exlude the files we don't need w/o uninstalling linux-firmware
echo "==> Setup dpkg excludes for linux-firmware"
sudo -E cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
#BENTO-BEGIN
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
#BENTO-END
_EOF_

# Delete the massive firmware packages
sudo -E rm -rf /lib/firmware/*
sudo -E rm -rf /usr/share/doc/linux-firmware/*


sudo -E apt-get -y autoremove;
sudo -E apt-get -y clean;

# Remove docs
sudo -E rm -rf /usr/share/doc/*

# Remove caches
sudo -E find /var/cache -type f -exec rm -rf {} \;

# delete any logs that have built up during the install
sudo -E find /var/log/ -name *.log -exec rm -f {} \;

# Disable sleep https://github.com/laravel/homestead/issues/1624
sudo -E systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# What are you doing Ubuntu?
# https://askubuntu.com/questions/1250974/user-root-cant-write-to-file-in-tmp-owned-by-someone-else-in-20-04-but-can-in
sudo -E sysctl fs.protected_regular=0

sudo -E chown -R ubuntu:ubuntu /home/ubuntu
sudo -E chown -R ubuntu:ubuntu /usr/local/bin

tee -a /home/ubuntu/.profile << EOF
PATH=$(sudo -E su ubuntu -c 'composer config -g home')/vendor/bin:\$PATH
alias mcomposer='php -d memory_limit=-1 $(which composer) '
alias artisan='php artisan'
alias a='php artisan'
alias tinker='php artisan tinker'
EOF

source /home/ubuntu/.profile
