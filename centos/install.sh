#!/bin/sh

# CentOS 8 install

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh

# Update CentOS 
verbose "Updating CentOS"
dnf -y update && dnf -y upgrade

# Add additional repository
#yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Installing basics packages
dnf -y install chrony yum-utils net-tools epel-release htop vim openssl
 
# Disable SELinux
resources/selinux.sh

read -n1 -p "Postgresql[1] or mysql[2] (beta) ?" sql
case $sql in
  p|P|1) sql=pgsql;;
  m|M|2) sql=mysql;;
  *)  sql=pgsql;;
esac
echo ""
echo "You selected: $sql"
echo ""

#FusionPBX
resources/fusionpbx.sh

if [ "$sql" == "pgsql" ]; then
  dnf module enable postgresql:15 -y
  #dnf install postgresql-server php-pgsql -y
  #postgresql-setup --initdb
  #sed -i s/ident/md5/ /var/lib/pgsql/data/pg_hba.conf
  #systemctl enable --now postgresql
  
#Postgres
resources/postgresql.sh
fi
if [ "$sql" == "mysql" ]; then
  dnf install mariadb-server php-mysqlnd -y
  systemctl enable --now mariadb
  mysql_secure_installation
fi

#NGINX web server
resources/sslcert.sh
resources/nginx.sh

#PHP/PHP-FPM
resources/php.sh

#Firewalld
resources/firewalld.sh

#FreeSWITCH
resources/switch.sh

#Fail2ban
resources/fail2ban.sh

#restart services
verbose "Restarting packages for final configuration"
systemctl daemon-reload
systemctl restart freeswitch
systemctl restart php-fpm
systemctl restart nginx
systemctl restart fail2ban

#add the database schema, user and groups
resources/finish.sh
