#!/bin/bash

#Установка PearDB(php-db):
wget http://ftp.debian.org/debian/pool/main/p/php-db/php-db_1.9.2-1_all.deb && \
apt install libsodium23 libxslt1.1 php-cli php-common php-pear php-xml php7.3-cli \
  php7.3-common php7.3-json php7.3-opcache php7.3-readline php7.3-xml psmisc -y && \
dpkg -i php-db_1.9.2-1_all.deb

#Установка Pjproject:
apt install git gcc g++ make -y && \
git clone https://github.com/pjsip/pjproject.git && \
cd pjproject/ && \
./configure  --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --libdir=/usr/lib64 && \
make dep && \
make && \
make install && \
cd ..

#Установка Lame:
wget https://kumisystems.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz && \
tar zxvf lame-3.100.tar.gz && \
cd lame-3.100/ && \
./configure && \
make && \
make install && \
cd ..;

#Установка dahdi:
#Устонвка из deb пакета:
#apt install autoconf automake autopoint autotools-dev build-essential debhelper \
#  dh-autoreconf dh-strip-nondeterminism dirmngr dpkg-dev dwz fakeroot gettext \
#  gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server \
#  gpgconf gpgsm intltool-debian libalgorithm-diff-perl \
#  libalgorithm-diff-xs-perl libalgorithm-merge-perl libarchive-cpio-perl \
#  libarchive-zip-perl libassuan0 libcroco3 libdpkg-perl libfakeroot \
#  libfile-fcntllock-perl libfile-stripnondeterminism-perl libglib2.0-0 \
#  libglib2.0-data libksba8 libltdl-dev libltdl7 libmail-sendmail-perl libnpth0 \
#  libsys-hostname-long-perl libtool m4 module-assistant pinentry-curses -y
#apt install debhelper module-assistant
#wget  http://ftp.br.debian.org/debian/pool/main/d/dahdi-linux/dahdi-source_2.11.1.0.20170917~dfsg-7_all.deb
#dpkg -i dahdi-source_2.11.1.0.20170917~dfsg-7_all.deb 
#Установка из исходников:
wget https://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz && \
tar -zxvf dahdi-linux-complete-current.tar.gz && \
apt install -y linux-headers-$(uname -r) libxml2 libssl-dev libncurses5 libncurses5-dev libnewt0.52 libnewt-dev vim-nox \
dh-autoreconf  autogen libtool shtool libglib2.0-dev && \
cd dahdi-linux-complete-3.1.0+3.1.0/ && \
make && make install && make install-config && \
systemctl start dahdi && \
systemctl enable dahdi && \
#systemctl status dahdi.service
cd ..;
# Вывод: помогла установка из исходного кода.

#Install jansson:

wget http://digip.org/jansson/releases/jansson-2.13.tar.gz && \
tar zvxf jansson-2.13.tar.gz && \
cd jansson-2.13/ && \
./configure --prefix=/usr && \
make clean && \
make && \
make install && \
ldconfig && \
cd ..;

# Install libpri

wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-1.6.0.tar.gz && \
tar xvfz libpri-1.6.0.tar.gz && \
cd libpri-1.6.0 && \
make && \
make install && \
cd ..

# Intsall postgres

apt install -y postgresql-11 postgresql-server-dev-11 sudo
sudo -Hiu postgres psql  -c "create user $1 with encrypted password '$2';" && \
sudo -Hiu postgres psql  -c "CREATE DATABASE $3;"
#sudo -Hiu postgres psql  -c "ALTER USER $1 WITH ENCRYPTED PASSWORD '$2';"
sudo -Hiu postgres psql  -c "grant all privileges on database $3 to $1;"
sudo -Hiu postgres psql  -c "\c $3;"
sudo -Hiu postgres psql  -c "CREATE TABLE cdr (
        calldate timestamp NOT NULL ,
        clid varchar (80) NOT NULL ,
        src varchar (80) NOT NULL ,
        dst varchar (80) NOT NULL ,
        dcontext varchar (80) NOT NULL ,
        channel varchar (80) NOT NULL ,
        dstchannel varchar (80) NOT NULL ,
        lastapp varchar (80) NOT NULL ,
        lastdata varchar (80) NOT NULL ,
        duration int NOT NULL ,
        billsec int NOT NULL ,
        disposition varchar (45) NOT NULL ,
        amaflags int NOT NULL ,
        accountcode varchar (20) NOT NULL ,
        uniqueid varchar (150) NOT NULL ,
        userfield varchar (255) NOT NULL ,
        peeraccount varchar(20) NOT NULL ,
        linkedid varchar(150) NOT NULL ,
        sequence int NOT NULL );"

# Install   asterisk

apt -y install libedit-dev uuid-dev libxml2-dev libsqlite3-dev subversion && \
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz && \
tar xvfz asterisk-18-current.tar.gz && \
cd asterisk-18.1.1/ && \
./configure --libdir=/usr/lib64 --with-postgres --with-dahdi --with-jansson-bundled && \
contrib/scripts/get_mp3_source.sh;

make && \
make install && \
make samples && \
make config && \
systemctl start asterisk && \
systemctl enable asterisk && \
cd ..;
 
# Создание пользователя 
useradd -m asterisk && \
chown asterisk.asterisk /var/run/asterisk && \
chown -R asterisk.asterisk /etc/asterisk && \
chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk && \
chown -R asterisk.asterisk /usr/lib64/asterisk && \
systemctl restart asterisk;

cp /etc/asterisk/cdr_pgsql.conf /etc/asterisk/cdr_pgsql.conf.old;