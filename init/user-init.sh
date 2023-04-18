#!/usr/bin/env bash

export PHP_VERSION=8.2
export NODE_VERSION=lts

export MYSQL_ROOT_PWD=secret
export MYSQL_USER=$USER
export MYSQL_USER_PWD=secret


if (( $EUID == 0 )); then
    echo 'Do not run as root'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

sudo -E tee /etc/apt/apt.conf.d/local << EOF
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
}
EOF

sudo -E apt update
sudo -E apt upgrade -y
sudo -E apt install -y software-properties-common curl p7zip zip unzip

# PPAs
sudo -E apt-add-repository ppa:ondrej/php -y
sudo -E apt-add-repository ppa:ondrej/nginx -y

sudo -E apt update

# NodeJS
sudo -E apt install -y npm
sudo -E npm install --global n
sudo -E n install $NODE_VERSION


sudo -E apt update

# PHP minimum (maybe) 
# sudo -E apt install --allow-change-held-packages -y php$PHP_VERSION \
# php$PHP_VERSION-common php$PHP_VERSION-curl php$PHP_VERSION-mbstring \
# php$PHP_VERSION-mysql php$PHP_VERSION-xml php$PHP_VERSION-zip php$PHP_VERSION-dom \
# php$PHP_VERSION-bcmath openssl php$PHP_VERSION-mbstring php$PHP_VERSION-fpm

# PHP from laravel/settler
sudo -E apt-get install -y --allow-change-held-packages \
php$PHP_VERSION \
php$PHP_VERSION-bcmath \
php$PHP_VERSION-bz2 \
php$PHP_VERSION-cgi \
php$PHP_VERSION-cli \
php$PHP_VERSION-common \
php$PHP_VERSION-curl \
php$PHP_VERSION-dba \
php$PHP_VERSION-dev \
php$PHP_VERSION-enchant \
php$PHP_VERSION-fpm \
php$PHP_VERSION-gd \
php$PHP_VERSION-gmp \
php$PHP_VERSION-imap \
php$PHP_VERSION-interbase \
php$PHP_VERSION-intl \
php$PHP_VERSION-ldap \
php$PHP_VERSION-mbstring \
php$PHP_VERSION-mysql \
php$PHP_VERSION-odbc \
php$PHP_VERSION-opcache \
php$PHP_VERSION-pgsql \
php$PHP_VERSION-phpdbg \
php$PHP_VERSION-pspell \
php$PHP_VERSION-readline \
php$PHP_VERSION-snmp \
php$PHP_VERSION-soap \
php$PHP_VERSION-sqlite3 \
php$PHP_VERSION-sybase \
php$PHP_VERSION-tidy \
php$PHP_VERSION-xml \
php$PHP_VERSION-xsl \
php$PHP_VERSION-zip

# Composer
sudo -E curl -sS https://getcomposer.org/installer | php
sudo -E mv composer.phar /usr/local/bin/composer
sudo -E chown -R $USER:$USER /home/$USER/.config

# Nginx
sudo -E apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages nginx
sudo -E rm /etc/nginx/sites-enabled/default
sudo -E rm /etc/nginx/sites-available/default


# Set The Nginx & PHP-FPM User
sudo -E sed -i "s/user www-data;/user $USER;/" /etc/nginx/nginx.conf
sudo -E sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sudo -E sed -i "s/user = www-data/user = $USER/" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
sudo -E sed -i "s/group = www-data/group = $USER/" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf

sudo -E sed -i "s/listen\.owner.*/listen.owner = $USER/" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
sudo -E sed -i "s/listen\.group.*/listen.group = $USER/" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf
sudo -E sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf

sudo -E usermod -aG www-data $USER
sudo -E id $USER
sudo -E groups $USER

sudo -E tee /etc/nginx/sites-available/laravel-server-block << _EOF_
server {
    listen 80;
    server_name www.example.com;
    root "/home/$USER/project/public";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$server_name-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/var/run/php/php$PHP_VERSION-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
_EOF_

# NodeJS and NPM and build tools
sudo -E apt-get install -y nodejs
sudo -E apt install -y make gcc g++

# Install MySQL
sudo -E apt-get install -y mysql-server

# Set MySQL password and create new user
sudo -E mysql -u root << _EOF_
ALTER USER 'root'@'localhost' identified by '$MYSQL_ROOT_PWD';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE USER '$MYSQL_USER'@'%' identified by '$MYSQL_USER_PWD';
GRANT ALL PRIVILEGES ON *.* to '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
_EOF_

sudo -E apt install -y supervisor

sudo -E snap install --classic certbot

sudo -E nginx -s reload
sudo -E service mysql restart
sudo -E service php$PHP_VERSION-fpm restart



