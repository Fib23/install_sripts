#!/bin/bash
#Установка SpanDSP
#Данный модуль необходим для работы с факсами. Если поддержка факсов не нужна, то можно смело пропустить установку этого модуля.

#Из репозиториев:
#apt-get install -y libspandsp2 libspandsp-dev

Из исходников:
cd /usr/src
wget http://soft-switch.org/downloads/spandsp/spandsp-0.0.6pre21.tgz
tar vxfz spandsp-*.tgz
rm -f spandsp-*.tgz
cd spandsp-*
./configure
make clean
make
make install


#Взято из https://blog.denisbondar.com/post/asterisk-13-chan_dongle-debian-8
