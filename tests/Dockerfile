FROM ubuntu-upstart:14.04

RUN apt-get update; apt-get -y upgrade
RUN apt-get -y install \
        gnupg2 haveged libgfshare-bin parcimonie \
        qrencode imagemagick zbar-tools wget realpath
RUN useradd -m testuser
