#!/bin/bash
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