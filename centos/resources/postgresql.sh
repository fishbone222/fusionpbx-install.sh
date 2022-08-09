#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing PostgreSQL"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

# Install the repository
sudo dnf module enable postgresql:13

# Install PostgreSQL:
sudo yum install -y postgresql-server postgresql-contrib postgresql postgresql-libs

#send a message
verbose "Initalize PostgreSQL database"

#initialize the database
sudo /usr/bin/postgresql-setup initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

#allow loopback
sed -i 's/\(host  *all  *all  *127.0.0.1\/32  *\)ident/\1md5/' /var/lib/pgsql/data/pg_hba.conf
sed -i 's/\(host  *all  *all  *::1\/128  *\)ident/\1md5/' /var/lib/pgsql/data/pg_hba.conf

#systemd
systemctl daemon-reload
systemctl restart postgresql

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp

#add the databases, users and grant permissions to them
sudo -u postgres /usr/bin/psql -d fusionpbx -c "DROP SCHEMA public cascade;";
sudo -u postgres /usr/bin/psql -d fusionpbx -c "CREATE SCHEMA public;";
sudo -u postgres /usr/bin/psql -c "CREATE DATABASE fusionpbx";
sudo -u postgres /usr/bin/psql -c "CREATE DATABASE freeswitch";
sudo -u postgres /usr/bin/psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/bin/psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
cd $cwd
verbose "PostgreSQL-password: $password"

#send a message
verbose "PostgreSQL installed"
