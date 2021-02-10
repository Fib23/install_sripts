#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "" ] || [ "$1" = "--help" ] || [ "$2" = "" ]
then
  echo "Usage:"
  echo "  nextcloud [ dbuser ] [ dbpass ] [ databaseuser ] [ databasepass ] [ databasename ] [ adminuser ] [ adminpass ]"
  echo "Options:"
  echo "  dbuser           User only root"
  echo "  dbpass           User root passoword"
  echo "  databaseuser     User name in db for nextcloud"
  echo "  databasepass     Password for databaseuser"
  echo "  databasename     Database name for nextcloud"
  echo "  adminuser        Admin user for web nextcloud"
  echo "  adminpass        Password for  adminuser"
  exit 0
fi

dbuser=$1;       #user system root
dbpass=$2;       #user root pass
databaseuser=$3; #user in db for nextcloud
databasepass=$4; #user pass
databasename=$5; #database name for nextcloud
adminuser=$6;    #name admin user for web nextcloud
adminpass=$7 ;   #pass for admin user

apt install git wget tree sudo -y  && \
apt install  apache2 mariadb-server -y && \
apt install lsb-release apt-transport-https ca-certificates -y;

#install PHP
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list && \
apt update && \
apt list --upgradable > /tmp/upgradable.log && \
apt upgrade -y && \
apt install php7.4 -y && \
apt install php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl -y && \
apt install php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip -y;

#install Nextcloud 20.0.7
wget https://download.nextcloud.com/server/releases/nextcloud-20.0.7.tar.bz2 && wget https://download.nextcloud.com/server/releases/nextcloud-20.0.7.tar.bz2.md5 && \
md5sum -c nextcloud-20.0.7.tar.bz2.md5 < nextcloud-20.0.7.tar.bz2 >> /tmp/upgradable.log && \
tar -xjvf nextcloud-20.0.7.tar.bz2 && \
cp -r nextcloud /var/www && \
cp /var/www/nextcloud/config/config.php /var/www/nextcloud/config/config.php.backup;

#settings  Apache2
echo 'Alias /nextcloud "/var/www/nextcloud/"

<Directory /var/www/nextcloud/>
  Require all granted
  AllowOverride All
  Options FollowSymLinks MultiViews

  <IfModule mod_dav.c>
    Dav off
  </IfModule>

</Directory>' > /etc/apache2/sites-available/nextcloud.conf && \
chown -R www-data:www-data /var/www/nextcloud/ && cd /var/www/nextcloud/ && \
a2ensite nextcloud.conf && \
a2enmod rewrite && a2enmod headers  && a2enmod env && a2enmod dir &&  a2enmod mime && a2enmod ssl && a2ensite default-ssl && \
systemctl reload apache2;

#settings Mysql
/etc/init.d/mysql start && \
echo "CREATE USER '$databaseuser'@'localhost' IDENTIFIED BY '$databasepass';" | mysql -u $dbuser -p$dbpass && \
echo "CREATE DATABASE IF NOT EXISTS $databasename CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" | mysql -u $dbuser -p$dbpass && \
echo "GRANT ALL PRIVILEGES ON $databasename.* TO '$databaseuser'@'localhost';" | mysql -u $dbuser -p$dbpass && \
echo "FLUSH PRIVILEGES;" | mysql -u $dbuser -p$dbpass && \
sudo -u www-data php occ  maintenance:install --database "mysql" --database-name "$databasename"  --database-user "$databaseuser" --database-pass "$databasepass" --admin-user "$adminuser" --admin-pass "$adminpass";

#
add=$(ip addr | grep -A 1 'enp1s0' | sed -n "/inet/p" | awk '{print $2}' | cut -d/ -f1) && sed -i "7a\    1 => '$add'," /var/www/nextcloud/config/config.php;


if [ "$8" = "--app-full" ]
then
#My app install for Nextcloud
  sudo -u www-data php /var/www/nextcloud/occ app:install onlyoffice && \
  sudo -u www-data php /var/www/nextcloud/occ app:install documentserver_community && \
  sudo -u www-data php /var/www/nextcloud/occ config:system:set allow_local_remote_servers --value true --type bool && \
  sudo -u www-data php /var/www/nextcloud/occ config:app:set onlyoffice DocumentServerUrl --value="https://$add/nextcloud/index.php/apps/documentserver_community/" # app onlyoffice

  sudo -u www-data php /var/www/nextcloud/occ app:install spreed && \
  sudo -u www-data php /var/www/nextcloud/occ app:install talk_simple_poll; # app Nextcloud Talk

  sudo -u www-data php /var/www/nextcloud/occ app:install tasks;
  sudo -u www-data php /var/www/nextcloud/occ app:install deck;
  sudo -u www-data php /var/www/nextcloud/occ app:install notes;
  sudo -u www-data php /var/www/nextcloud/occ app:install calendar;
  sudo -u www-data php /var/www/nextcloud/occ app:install groupfolders;
  sudo -u www-data php /var/www/nextcloud/occ app:install mail;
  sudo -u www-data php /var/www/nextcloud/occ files_sharing;
fi
