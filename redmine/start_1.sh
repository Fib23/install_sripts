#!/bin/bash
#
#https://www.redmine.org/projects/redmine/wiki/HowTo_Install_Redmine_on_Debian_9
#
if [ "$1" = "-h" ] || [ "$1" = "" ] || [ "$1" = "--help" ] || [ "$2" = "" ]
then
  echo "Usage:"
  echo "  redmine [ databaseuser ] [ databasepass ] [ databasename ] [ adminuser ] [ adminpass ]"
  echo "Options:"
  echo "  databaseuser     User name in db for redmine"
  echo "  databasepass     Password for databaseuser"
  echo "  databasename     Database name for redmine"
  exit 0
fi

databaseuser=$1; #user in db for nextcloud
databasepass=$2; #user pass
databasename=$3; #database name for nextcloud

# 1.Install the pre-requisites for Redmine and all its packages.
apt install sudo gcc build-essential zlib1g zlib1g-dev zlibc ruby-zip libssl-dev libyaml-dev libcurl4-openssl-dev ruby gem libapache2-mod-passenger apache2 apache2-dev \
 libapr1-dev libxslt1-dev  libxml2-dev ruby-dev vim  libmagickwand-dev imagemagick sudo rails -y && \
wget http://ftp.debian.org/debian/pool/main/c/checkinstall/checkinstall_1.6.2+git20170426.d24a630-2~bpo10+1_amd64.deb && \
dpkg -i checkinstall_1.6.2+git20170426.d24a630-2~bpo10+1_amd64.deb && \
rm checkinstall*;

# 2.Install your databese of choice
apt install postgresql-server-dev-11 postgresql-11 -y;

# 3.Choose a directory where to install Redmine.  In this example /opt used.  You can use another location, but you will need to update the following steps as necessary based on your choice. -- sudo
mkdir /opt/redmine && \
cd /opt/redmine;
wget http://www.redmine.org/releases/redmine-4.1.1.tar.gz && tar xzf ./redmine-4.1.1.tar.gz && rm redmine*.tar.gz;

# 4. DB
echo "CREATE ROLE $databaseuser LOGIN ENCRYPTED PASSWORD '$databasepass' NOINHERIT VALID UNTIL 'infinity'; CREATE DATABASE $databasename WITH ENCODING='UTF8' OWNER=$databaseuser;" > ps.sql && \
sudo -i -H -u postgres psql postgres < ps.sql && rm *.sql;
sed -i  's/local   all             postgres                                peer/local   all             postgres                                trust/g'  /etc/postgresql/11/main/pg_hba.conf && sudo service postgresql reload;

# 5
printf "production:\n  adapter: postgresql\n  database: $databasename\n  host: localhost\n  username: $databaseuser\n  password: $databasepass" > /opt/redmine/redmine-4.1.1/config/database.yml;
mkdir -p /opt/redmine/redmine-4.1.1/app/assets/config/;
printf "// app/assets/config/manifest.js\n//\n//= link application.css\n//= link marketing.css\n//\n//= link application.js" > /opt/redmine/redmine-4.1.1/app/assets/config/manifest.js;

# 6
sudo -i -H -u test cd /opt/redmine/redmine-4.1.1/config/ && bundle install && \
bundle exec rake generate_secret_token && \
RAILS_ENV=production bundle exec rake db:migrate && \
RAILS_ENV=production bundle exec rake redmine:load_default_data;
#ipv4=$(ip addr | grep -A 1 'enp1s0' | sed -n "/inet/p" | awk '{print $2}' | cut -d/ -f1)
#bundle exec ruby /usr/bin/rails server -b $ipv4 webrick -e production

chown -R www-data:www-data /opt/redmine && \
cd /opt/redmine/redmine-4.1.1 && \
chmod -R 755 files log tmp public/plugin_assets && \
chown www-data:www-data Gemfile.lock && \
ln -s /opt/redmine/redmine-4.1.1/public/ /var/www/html/redmine && \
printf "<VirtualHost *:80>\n\nServerAdmin admin@example.com\nServername hostname\nDocumentRoot /var/www/html/\n\n"  > /etc/apache2/sites-available/master.conf && \
printf "<Location /redmine>\nRailsEnv production\nRackBaseURI /redmine\nOptions -MultiViews\n</Location>\n\n</VirtualHost>" >> /etc/apache2/sites-available/master.conf && \
a2dissite 000-default.conf && \
a2ensite master.conf && \
sed -i "3a\  PassengerUser www-data" /etc/apache2/mods-available/passenger.conf  && \
service apache2 restart;



