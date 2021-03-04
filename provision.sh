#!/bin/bash

if (( $EUID == 0 ))
then
	echo 'Do not run as root'
	exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# *** Run using `bash Provision.sh` DO NOT RUN USING SUDO ***

# These are the default settings...
# username = ubuntu
# mysql_password = secret
# timezone = UTC

# Change before running by using `sed -i 's/ubuntu/someusername/g' Provision.sh` for example.

sudo -E tee /etc/apt/apt.conf.d/local << EOF
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
}
EOF

sudo -E apt-get update
sudo -E apt-get -y upgrade

echo "LC_ALL=en_US.UTF-8" | sudo -E tee -a /etc/default/locale
sudo -E locale-gen en_US.UTF-8

sudo -E apt-add-repository universe -y
sudo -E apt-add-repository ppa:nginx/development -y
sudo -E apt-add-repository ppa:ondrej/php -y
sudo -E add-apt-repository ppa:certbot/certbot -y

sudo -E apt-get update

sudo -E apt-get install -y software-properties-common libmcrypt4 libpcre3-dev libpng-dev curl unzip mcrypt git supervisor 

sudo -E ln -sf /usr/share/zoneinfo/UTC /etc/localtime

sudo -E apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
php7.3-cli php7.3-dev \
php7.3-pgsql php7.3-sqlite3 php7.3-gd \
php7.3-curl \
php7.3-imap php7.3-mysql php7.3-mbstring \
php7.3-xml php7.3-zip php7.3-bcmath php7.3-soap \
php7.3-intl php7.3-readline

# PHP 7.4
sudo -E apt-get install -y --allow-change-held-packages \
php7.4-cli php7.4-bcmath php7.4-curl php7.4-dev php7.4-gd php7.4-imap php7.4-intl  php7.4-json  php7.4-ldap \
php7.4-mbstring php7.4-mysql php7.4-odbc php7.4-pgsql php7.4-phpdbg php7.4-pspell php7.4-soap php7.4-sqlite3 \
php7.4-xml php7.4-zip php7.4-readline

# PHP 8.0
sudo -E apt-get install -y --allow-change-held-packages \
php8.0 php8.0-bcmath php8.0-bz2 php8.0-cgi php8.0-cli php8.0-common php8.0-curl php8.0-dba php8.0-dev \
php8.0-enchant php8.0-fpm php8.0-gd php8.0-gmp php8.0-imap php8.0-interbase php8.0-intl php8.0-ldap \
php8.0-mbstring php8.0-mysql php8.0-odbc php8.0-opcache php8.0-pgsql php8.0-phpdbg php8.0-pspell php8.0-readline \
php8.0-snmp php8.0-soap php8.0-sqlite3 php8.0-sybase php8.0-tidy php8.0-xml php8.0-xsl php8.0-zip

sudo -E update-alternatives --set php /usr/bin/php8.0
sudo -E update-alternatives --set php-config /usr/bin/php-config8.0
sudo -E update-alternatives --set phpize /usr/bin/phpize8.0

curl -sS https://getcomposer.org/installer | php
sudo -E mv composer.phar /usr/local/bin/composer

/usr/local/bin/composer global require "laravel/envoy=^2.0"
/usr/local/bin/composer global require "laravel/installer=^4.0.2"
/usr/local/bin/composer global require "laravel/spark-installer=dev-master"
/usr/local/bin/composer global require "slince/composer-registry-manager=^2.0"

sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/cli/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/cli/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/cli/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/cli/php.ini

sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini

sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/cli/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/cli/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/cli/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/cli/php.ini

sudo -E apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
nginx php7.3-fpm php7.4-fpm

sudo -E rm /etc/nginx/sites-enabled/default
sudo -E rm /etc/nginx/sites-available/default

sudo -E echo "xdebug.remote_enable = 1" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "xdebug.remote_connect_back = 1" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "xdebug.remote_port = 9000" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "xdebug.max_nesting_level = 512" >> /etc/php/8.0/mods-available/xdebug.ini
sudo -E echo "opcache.revalidate_freq = 0" >> /etc/php/8.0/mods-available/opcache.ini

sudo -E echo "xdebug.remote_enable = 1" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "xdebug.remote_connect_back = 1" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "xdebug.remote_port = 9000" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "xdebug.max_nesting_level = 512" >> /etc/php/7.4/mods-available/xdebug.ini
sudo -E echo "opcache.revalidate_freq = 0" >> /etc/php/7.4/mods-available/opcache.ini

sudo -E echo "xdebug.remote_enable = 1" >> /etc/php/7.3/mods-available/xdebug.ini
sudo -E echo "xdebug.remote_connect_back = 1" >> /etc/php/7.3/mods-available/xdebug.ini
sudo -E echo "xdebug.remote_port = 9000" >> /etc/php/7.3/mods-available/xdebug.ini
sudo -E echo "xdebug.max_nesting_level = 512" >> /etc/php/7.3/mods-available/xdebug.ini
sudo -E echo "opcache.revalidate_freq = 0" >> /etc/php/7.3/mods-available/opcache.ini

sudo -E sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/fpm/php.ini
sudo -E sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/fpm/php.ini
sudo -E sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini
sudo -E sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
sudo -E sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.3/fpm/php.ini
sudo -E sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.3/fpm/php.ini
sudo -E sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/fpm/php.ini

sudo -E printf "[openssl]\n" | tee -a /etc/php/7.3/fpm/php.ini
sudo -E printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.3/fpm/php.ini

sudo -E printf "[curl]\n" | tee -a /etc/php/7.3/fpm/php.ini
sudo -E printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.3/fpm/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini

printf "[openssl]\n" | tee -a /etc/php/7.4/fpm/php.ini
printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini

printf "[curl]\n" | tee -a /etc/php/7.4/fpm/php.ini
printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini

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

sudo -E phpdismod -s cli xdebug

sudo -E cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param	QUERY_STRING		\$query_string;
fastcgi_param	REQUEST_METHOD		\$request_method;
fastcgi_param	CONTENT_TYPE		\$content_type;
fastcgi_param	CONTENT_LENGTH		\$content_length;
fastcgi_param	SCRIPT_FILENAME		\$request_filename;
fastcgi_param	SCRIPT_NAME		\$fastcgi_script_name;
fastcgi_param	REQUEST_URI		\$request_uri;
fastcgi_param	DOCUMENT_URI		\$document_uri;
fastcgi_param	DOCUMENT_ROOT		\$document_root;
fastcgi_param	SERVER_PROTOCOL		\$server_protocol;
fastcgi_param	GATEWAY_INTERFACE	CGI/1.1;
fastcgi_param	SERVER_SOFTWARE		nginx/\$nginx_version;
fastcgi_param	REMOTE_ADDR		\$remote_addr;
fastcgi_param	REMOTE_PORT		\$remote_port;
fastcgi_param	SERVER_ADDR		\$server_addr;
fastcgi_param	SERVER_PORT		\$server_port;
fastcgi_param	SERVER_NAME		\$server_name;
fastcgi_param	HTTPS			\$https if_not_empty;
fastcgi_param	REDIRECT_STATUS		200;
EOF

sudo -E sed -i "s/user = www-data/user = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
sudo -E sed -i "s/group = www-data/group = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf

sudo -E sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
sudo -E sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
sudo -E sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.0/fpm/pool.d/www.conf

sudo -E sed -i "s/user www-data;/user ubuntu;/" /etc/nginx/nginx.conf
sudo -E sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sudo -E sed -i "s/user = www-data/user = ubuntu/" /etc/php/7.3/fpm/pool.d/www.conf
sudo -E sed -i "s/group = www-data/group = ubuntu/" /etc/php/7.3/fpm/pool.d/www.conf

sudo -E sed -i "s/listen\.owner.*/listen.owner = ubuntu/" /etc/php/7.3/fpm/pool.d/www.conf
sudo -E sed -i "s/listen\.group.*/listen.group = ubuntu/" /etc/php/7.3/fpm/pool.d/www.conf
sudo -E sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.3/fpm/pool.d/www.conf

sudo -E sed -i "s/user = www-data/user = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
sudo -E sed -i "s/group = www-data/group = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf

sudo -E sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
sudo -E sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
sudo -E sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.4/fpm/pool.d/www.conf

sudo -E service nginx restart
sudo -E service php7.3-fpm restart
sudo -E service php7.4-fpm restart
sudo -E service php8.0-fpm restart

#sudo -E apt-get install -y certbot python-certbot-nginx # Changed to snap below
sudo -E snap install --classic certbot

sudo -E usermod -a -G www-data ubuntu
sudo -E id ubuntu
sudo -E groups ubuntu

sudo -E apt-get install -y nodejs

if [[ ! -f /usr/bin/npm ]]
then
    curl -L https://npmjs.org/install.sh | sudo -E sh
fi

sudo -E chown -R ubuntu:ubuntu /usr/lib/node_modules
sudo -E chown -R ubuntu:ubuntu $HOME/.npm

npm install -g npm

sudo -E echo "mysql-server mysql-server/root_password password secret" | debconf-set-selections
sudo -E echo "mysql-server mysql-server/root_password_again password secret" | debconf-set-selections
sudo -E apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" mysql-server

sudo -E echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

sudo -E sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo -E mysql --user="root" --password="secret" <<'EOF'
DROP USER 'root'@'localhost';
CREATE USER 'root'@'%' IDENTIFIED BY 'secret';
GRANT ALL PRIVILEGES ON *.* to 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

sudo -E service mysql restart

tee /home/ubuntu/.my.cnf <<EOL
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_bin
EOL

sudo -E mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password="secret" mysql

sudo -E service mysql restart

sudo -E apt-get -y upgrade

sudo -E apt-get -y autoremove
sudo -E apt-get -y clean
sudo -E chown -R ubuntu:ubuntu /home/ubuntu
sudo -E chown -R ubuntu:ubuntu /usr/local/bin

tee -a /home/ubuntu/.profile << EOF
PATH=$(sudo -E su ubuntu -c 'composer config -g home')/vendor/bin:\$PATH
alias mcomposer='php -d memory_limit=-1 $(which composer) '
EOF

source /home/ubuntu/.profile

