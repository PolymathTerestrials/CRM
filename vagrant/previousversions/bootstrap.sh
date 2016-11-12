#!/usr/bin/env bash

#=============================================================================
# DB Setup
rm -rf /var/www/public/*
launchversion=`grep -i '^[^#;]' /vagrant/VersionToLaunch`


if [ $launchversion == "1.2.14" ] ; then
  echo "bootstrapping 1.2.14"
  wget -nv -O /var/www/1.2.14.zip http://downloads.sourceforge.net/project/churchinfo/churchinfo/1.2.14/churchinfo-1.2.14.zip
  unzip -d /var/www/public /var/www/1.2.14.zip
  shopt -s dotglob
  mv  /var/www/public/churchinfo/* /var/www/public/
  CRM_DB_INSTALL_SCRIPT="/vagrant/src/SQL/Install.sql"
  CRM_DB_USER="churchinfo"
  CRM_DB_PASS="churchinfo"
  CRM_DB_NAME="churchinfo"

elif [[ $launchversion =~ [2\.] ]] ; then
  echo "bootstrapping $launchversion"
  filename=ChurchCRM-$launchversion.zip
  wget -nv -O /var/www/$filename https://github.com/ChurchCRM/CRM/releases/download/$launchversion/$filename
  unzip -d /var/www/public /var/www/$filename
  shopt -s dotglob  
  mv  /var/www/public/churchcrm/* /var/www/public/
  CRM_DB_INSTALL_SCRIPT="/vagrant/src/mysql/install/Install.sql"
  CRM_DB_USER="churchcrm"
  CRM_DB_PASS="churchcrm"
  CRM_DB_NAME="churchcrm"

else
  echo "version string not valid"
  exit 1
fi

DB_USER="root"
DB_PASS="root"
DB_HOST="localhost"



RET=1
while [[ RET -ne 0 ]]; do
    echo "Database: Waiting for confirmation of MySQL service startup"
    sleep 5
    sudo mysql -u"$DB_USER" -p"$DB_PASS" -e "status" > /dev/null 2>&1
    RET=$?
done

echo "Database: mysql started"

sudo mysql -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE $CRM_DB_NAME CHARACTER SET utf8;"

echo "Database: created"

sudo mysql -u"$DB_USER" -p"$DB_PASS" -e "CREATE USER '$CRM_DB_USER'@'$DB_HOST' IDENTIFIED BY '$CRM_DB_PASS';"
sudo mysql -u"$DB_USER" -p"$DB_PASS" -e "GRANT ALL PRIVILEGES ON $CRM_DB_NAME.* TO '$CRM_DB_NAME'@'$DB_HOST' WITH GRANT OPTION;"

echo "Database: user created with needed PRIVILEGES"

sudo mysql -u"$CRM_DB_USER" -p"$CRM_DB_PASS" "$CRM_DB_NAME" < $CRM_DB_INSTALL_SCRIPT

echo "Database: tables and metadata deployed"


#=============================================================================
# Help info

echo "============================================================================="
echo "======== ChurchCRM is now hosted @ http://192.168.33.12/       =============="
echo "======== Version is: $launchversion                            =============="
echo "======== CRM User Name: admin                                  =============="
echo "======== 1st time login password for admin: changeme           =============="
echo "============================================================================="
