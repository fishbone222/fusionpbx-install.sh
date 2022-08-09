#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Install PHP and PHP-FPM"

#set the version of php
#yum-config-manager --enable remi-php70
#yum-config-manager --enable remi-php71
#yum-config-manager --enable remi-php72
dnf module enable php:7.2

#dnf install -y http://www.nosuchhost.net/~cheese/fedora/packages/epel-8/x86_64/cheese-release-8-1.el8.noarch.rpm
#dnf install -y php-imap 

#install dependencies
dnf -y install php-fpm php-gd php-pgsql php-odbc php-curl php-opcache php-common php-pdo php-soap php-xml php-xmlrpc php-cli php-gd php-json

#send a message
verbose "Configuring php/nginx/php-fpm and permissions"

#get the timezone
TIMEZ=$(timedatectl | grep 'Time zone' | awk '{ print $3 }')

#update the php configuration
sed -ie "s#;date.timezone =#date.timezone = $TIMEZ#g" /etc/php.ini
sed -ie 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -ie "s|listen = 127.0.0.1:9000|listen = /var/run/php-fpm/php-fpm.sock|g" /etc/php-fpm.d/www.conf
sed -ie 's/;listen.owner = nobody/listen.owner = freeswitch/g' /etc/php-fpm.d/www.conf
sed -ie 's/;listen.group = nobody/listen.group = daemon/g' /etc/php-fpm.d/www.conf
sed -ie 's/group = apache/group = daemon/g' /etc/php-fpm.d/www.conf

#update the php.ini
#sed -ie 's/post_max_size = .*/post_max_size = 80M/g' /etc/php.ini
#sed -ie 's/upload_max_filesize = .*/upload_max_filesize = 80M/g' /etc/php.ini
#sed -ie 's/; max_input_vars = .*/max_input_vars = 8000/g' /etc/php.ini

#make the session directory
mkdir -p /var/lib/php/session

#update permissions
chmod -Rf 770 /var/lib/php/session

#update the permissions
find /var/www/fusionpbx -type d -exec chmod 770 {} \;
find /var/www/fusionpbx -type f -exec chmod 664 {} \;

#send a message
verbose "php/nginx/php-fpm and permissions configured"
